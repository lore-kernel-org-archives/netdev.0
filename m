From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: net: uninitialized loopback addr leaks to userspace
Date: Sun, 07 Jun 2009 16:03:27 -0500
Message-ID: <1244408607.9064.8.camel@Maple>
References: <19f34abd0905301323k1498ca3fv31b271de65d60afc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	LKML <linux-kernel@vger.kernel.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:12685 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212AbZFGVD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 17:03:28 -0400
In-Reply-To: <19f34abd0905301323k1498ca3fv31b271de65d60afc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-05-30 at 22:23 +0200, Vegard Nossum wrote:
> It seems that loopback's hardware address is never initialized by the
> kernel. So if userspace attempts to read this address before it has
> been set, the kernel will return some uninitialized data (only 6
> bytes, though).

Thank you for the report, Vegard.

I've been unable to reproduce the problem you describe, using
2.6-30-rc8, this test program and a couple of kernel builds for system
load:

------------------------------------------------------------------
#define REPEAT_COUNT 10000

int childTask() {
	struct ifreq ifreq;
	int fd;
	unsigned char allBits;

	fd = socket(AF_INET, SOCK_DGRAM, 0);
	if (fd < 0){
		printf("Error %s from socket()\n", strerror(errno));
		_exit(-1);
	}

	strncpy(ifreq.ifr_name, "lo", sizeof("lo"));
	if (ioctl (fd, SIOCGIFHWADDR, &ifreq) < 0){
		printf("Error %s from ioctl(SIOCGIFHWADDR) for %s.\n", strerror(errno), ifreq.ifr_name);
		_exit(-1);
	}
	
	allBits = ifreq.ifr_hwaddr.sa_data[0] |
			ifreq.ifr_hwaddr.sa_data[1] |
			ifreq.ifr_hwaddr.sa_data[2] |
			ifreq.ifr_hwaddr.sa_data[3] |
			ifreq.ifr_hwaddr.sa_data[4] |
			ifreq.ifr_hwaddr.sa_data[5];

	if (allBits != 0)
		printf("Device %s -> Ethernet %02x:%02x:%02x:%02x:%02x:%02x\n", ifreq.ifr_name,
			(int) ((unsigned char *) &ifreq.ifr_hwaddr.sa_data)[0],
			(int) ((unsigned char *) &ifreq.ifr_hwaddr.sa_data)[1],
			(int) ((unsigned char *) &ifreq.ifr_hwaddr.sa_data)[2],
			(int) ((unsigned char *) &ifreq.ifr_hwaddr.sa_data)[3],
			(int) ((unsigned char *) &ifreq.ifr_hwaddr.sa_data)[4],
			(int) ((unsigned char *) &ifreq.ifr_hwaddr.sa_data)[5]);
}


int main(int argc, char *argv[]) {
   	void **child_stack;
	int pid, i, status;

	child_stack = (void **) malloc(16384);

	for (i = 0; i < REPEAT_COUNT; i++){

		pid = clone(childTask, child_stack, CLONE_NEWNET, NULL);
		if (pid < 0){
			printf("Error %s from clone()\n", strerror(errno));
			_exit(-1);
		}
		
		pid = waitpid(pid, &status, __WCLONE);
		if (pid < 0){
			printf("Error %s from waitpid()\n", strerror(errno));
			_exit(-1);
		}
	}   
      
	return 0;
}
------------------------------------------------------------------

Looking at the kernel code, it appears that all bytes of struct
net_device, including the L2 address, are initialized to zeros at
interface creation time.

Can you spot a difference between your test procedures and mine that
would enable me to reproduce the problem?

  --  John

