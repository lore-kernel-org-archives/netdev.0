From: Rongqing Li <rongqing.li@windriver.com>
Subject: Re: [PATCH 0/2] Dump the sock's security context
Date: Wed, 31 Aug 2011 16:38:23 +0800
Message-ID: <4E5DF2FF.7000803@windriver.com>
References: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------030801010906080102050302"
Cc: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>
To: <rongqing.li@windriver.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--------------030801010906080102050302
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 08/31/2011 04:36 PM, rongqing.li@windriver.com wrote:
> -------
>      Any review would be much appreciated.
>
> Comments:
> --------
>      Add a netlink attribute INET_DIAG_SECCTX
>
>      Add a new netlink attribute INET_DIAG_SECCTX to dump the security
>      context of TCP sockets.
>
>      The element sk_security of struct sock represents the socket
>      security context ID, which is inherited from the parent process
>      when the socket is created.
>
>      but when SELinux type_transition rule is applied to socket, or
>      application sets /proc/xxx/attr/createsock, the socket security
>      context would be different from the creating process. For these
>      conditions, the "netstat -Z" would return wrong value, since
>      "netstat -Z" only returns the process security context as socket
>      process security.
>
>
> The application to verify the netlink new attribute.
> ------
> See attached file
>
> test:
> --------
> 1. Enable SELinux when compile and startup .
> 	root@qemu-host:/root>  ./printsocketsec
> 	 inode:7141 system_u:system_r:rpcbind_t:s0
> 	 inode:7136 system_u:system_r:rpcbind_t:s0
> 	 inode:7604 system_u:system_r:initrc_t:s0
> 	 inode:7227 system_u:system_r:rpcd_t:s0
> 	 inode:7471 system_u:system_r:sshd_t:s0-s0:c0.c1023
> 	 inode:7469 system_u:system_r:sshd_t:s0-s0:c0.c1023
> 	 inode:7552 system_u:system_r:sendmail_t:s0
> 	 inode:7348 system_u:system_r:initrc_t:s0
> 	 inode:7553 system_u:system_r:sendmail_t:s0
> 	root@qemu-host:/root>
>
> 2. Disable SELinux when startup.
> 	root@qemu-host:/root>  ./printsocketsec
> 	inode:3221
> 	inode:2942
> 	inode:2861
> 	inode:3256
> 	inode:3156
> 	inode:3220
> 	inode:3060
> 	root@qemu-host:/root>
>
> 3. Disable SELinux when compile and startup
> 	root@qemu-host:/root>  ./printsocketsec
> 	inode:3221
> 	inode:2942
> 	inode:2861
> 	inode:3256
> 	inode:3156
> 	inode:3220
> 	inode:3060
> 	root@qemu-host:/root>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

-- 
Best Reagrds,
Roy | RongQing Li

--------------030801010906080102050302
Content-Type: text/x-csrc; name="printsocketsec.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="printsocketsec.c"

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>

#include "libnetlink.h"

#include <netinet/tcp.h>
#include <linux/inet_diag.h>

enum {
        SS_UNKNOWN,
        SS_ESTABLISHED,
        SS_SYN_SENT,
        SS_SYN_RECV,
        SS_FIN_WAIT1,
        SS_FIN_WAIT2,
        SS_TIME_WAIT,
        SS_CLOSE,
        SS_CLOSE_WAIT,
        SS_LAST_ACK,
        SS_LISTEN,
        SS_CLOSING,
        SS_MAX
};

#define SS_ALL ((1<<SS_MAX)-1)

/*The INET_DIAG_SECCTX should be defined in inet_diag.h at last,
To simply the test, I define it locally*/
#define INET_DIAG_SECCTX (INET_DIAG_CONG+1)
#define LOCAL_MAX INET_DIAG_SECCTX+1


void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
{

	struct rtattr * tb[ LOCAL_MAX + 1];

	printf(" inode:%u", r->idiag_inode);

	parse_rtattr(tb, LOCAL_MAX, (struct rtattr*)(r+1),
		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));


	if (tb[INET_DIAG_SECCTX])
		printf(" %s", (char *) RTA_DATA(tb[INET_DIAG_SECCTX]));
	printf("\n");
}

static int tcp_show_netlink( int socktype)
{
	int fd;
	struct sockaddr_nl nladdr;
	struct {
		struct nlmsghdr nlh;
		struct inet_diag_req r;
	} req;

	struct msghdr msg;
	struct rtattr rta;
	char	buf[8192];
	struct iovec iov[3];

	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
		return -1;

	memset(&nladdr, 0, sizeof(nladdr));
	nladdr.nl_family = AF_NETLINK;

	req.nlh.nlmsg_len = sizeof(req);
	req.nlh.nlmsg_type = socktype;
	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
	req.nlh.nlmsg_pid = 0;
	req.nlh.nlmsg_seq = 123456;
	memset(&req.r, 0, sizeof(req.r));
	req.r.idiag_family = AF_INET;
	req.r.idiag_states = SS_ALL;

	req.r.idiag_ext |= (1<<(INET_DIAG_SECCTX-1));

	iov[0] = (struct iovec){
		.iov_base = &req,
		.iov_len = sizeof(req)
	};

	msg = (struct msghdr) {
		.msg_name = (void*)&nladdr,
		.msg_namelen = sizeof(nladdr),
		.msg_iov = iov,
		.msg_iovlen = 1,
	};

	if (sendmsg(fd, &msg, 0) < 0)
		return -1;

	iov[0] = (struct iovec){
		.iov_base = buf,
		.iov_len = sizeof(buf)
	};

	while (1) {
		int status;
		struct nlmsghdr *h;

		msg = (struct msghdr) {
			(void*)&nladdr, sizeof(nladdr),
			iov,	1,
			NULL,	0,
			0
		};

		status = recvmsg(fd, &msg, 0);

		if (status < 0) {
			if (errno == EINTR)
				continue;
			perror("OVERRUN");
			continue;
		}
		if (status == 0) {
			fprintf(stderr, "EOF on netlink\n");
			return 0;
		}

		h = (struct nlmsghdr*)buf;
		while (NLMSG_OK(h, status)) {
			struct inet_diag_msg *r = NLMSG_DATA(h);

			if (/*h->nlmsg_pid != rth->local.nl_pid ||*/
			    h->nlmsg_seq != 123456)
				goto skip_it;

			if (h->nlmsg_type == NLMSG_DONE)
				return 0;

			if (h->nlmsg_type == NLMSG_ERROR) 
				return 0;

			tcp_show_info(h, r);
skip_it:
			h = NLMSG_NEXT(h, status);
		}
	}
	return 0;
}
void main()
{
	tcp_show_netlink( TCPDIAG_GETSOCK);
}

--------------030801010906080102050302--
