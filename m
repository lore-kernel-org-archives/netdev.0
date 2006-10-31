From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: sendmsg, descriptors and no content
Date: Tue, 31 Oct 2006 23:43:45 +0100
Message-ID: <20061031224345.GA7033@outpost.ds9a.nl>
References: <20061031220101.GA3545@colo.weary.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:53643 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1946060AbWJaWnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 17:43:47 -0500
To: netdev@weary.nl
Content-Disposition: inline
In-Reply-To: <20061031220101.GA3545@colo.weary.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 31, 2006 at 11:01:01PM +0100, netdev@weary.nl wrote:
> When I use sendmsg to send descriptors from one process to another using
> unix-sockets I need to include at least one byte of normal data for the
> descriptors to be send (using the iovec structure). The same code worked

W. R. Stevens, Unix Network Programming (2nd ed), vol 1, p. 389 recommends
sending at least a byte anyhow, which allows you to detect EOF.

Also see
http://www.cs-ipv6.lancs.ac.uk/ipv6/mail-archive/LinuxNetdev/1998-03/0144.html 
however.

I've attached an example that appears to work.

	Bert

#include <sys/socket.h>
#include <stdio.h>

int sfd(int passfd, int fd, int data)
{
    char cbuf[CMSG_SPACE(sizeof(int))];
    struct msghdr mh = { 0 };
    struct cmsghdr *cm;
    int *dp;
    struct iovec iov;

    if (fd >= 0) {
	mh.msg_control = cbuf;
	mh.msg_controllen = sizeof cbuf;
	cm = CMSG_FIRSTHDR(&mh);
	cm->cmsg_len = CMSG_LEN(sizeof(int));
	cm->cmsg_level = SOL_SOCKET;
	cm->cmsg_type = SCM_RIGHTS;

	dp = CMSG_DATA(cm);
	*dp = fd;
    }
    if (data != 0) {
	iov.iov_base = &data;
	iov.iov_len = sizeof data;
	mh.msg_iov = &iov;
	mh.msg_iovlen = 1;
    }

    return sendmsg(passfd, &mh, 0);
}

/* Only prepared to rcv one fd per message */
int rcvfd(int passfd, int *data, int *datalen)
{
    char cbuf[CMSG_SPACE(sizeof(int))];
    struct msghdr mh = { 0 };
    struct cmsghdr *cm;
    int *dp, ret;
    struct iovec iov;

    if (data) {
	mh.msg_iov = &iov;
	mh.msg_iovlen = 1;
	iov.iov_base = &data;
	iov.iov_len = sizeof(int);
    }

    mh.msg_control = cbuf;
    mh.msg_controllen = sizeof cbuf;
    cm = CMSG_FIRSTHDR(&mh);
    cm->cmsg_len = CMSG_LEN(sizeof(int));
    cm->cmsg_level = SOL_SOCKET;
    cm->cmsg_type = SCM_RIGHTS;

    *datalen = 0;
    ret = recvmsg(passfd, &mh, 0);
    if (ret < 0)
	return ret;
    if (datalen)
	*datalen = ret;

    dp = CMSG_DATA(cm);
    return *dp;
}

int main()
{
  int fd[2];
  int datalen;

  socketpair(AF_UNIX, SOCK_DGRAM, 0, fd);

  printf("Sending returned status: %d\n", sfd(fd[0], 0, 1));
  
  printf("Received fd: %d\n", rcvfd(fd[1], 0, &datalen));
  
}

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
