From: David Miller <davem@davemloft.net>
Subject: Re: Information leak in llcp_sock_bind/llcp_raw_sock_bind
Date: Tue, 15 Dec 2015 15:36:26 -0500 (EST)
Message-ID: <20151215.153626.1500179484827859040.davem@davemloft.net>
References: <CACT4Y+bjSFyXZi1PKTUsT9PhAYvCGiGjRkOBRbUON0Pw7rJxGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	sameo@linux.intel.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	syzkaller@googlegroups.com, edumazet@google.com, kcc@google.com,
	glider@google.com, sasha.levin@oracle.com
To: dvyukov@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+bjSFyXZi1PKTUsT9PhAYvCGiGjRkOBRbUON0Pw7rJxGg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 15 Dec 2015 21:00:20 +0100

> The problem is that llcp_sock_bind/llcp_raw_sock_bind do not check
> sockaddr_len passed in, so they copy stack garbage from stack into the
> socket and then return it in getsockname.
> This can defeat ASLR, leak crypto keys, etc.

That's actually the first thing these functions do.

They completely clear out the on-stack llcp_addr, then they copy only
as much as the user gave them, being careful not to use more than
sizeof(llcp_addr).

	memset(&llcp_addr, 0, sizeof(llcp_addr));
	len = min_t(unsigned int, sizeof(llcp_addr), alen);
	memcpy(&llcp_addr, addr, len);

I don't see what the problem is, you'll need to be more specific.

Even wrt. llcp_sock->service_name, the code limits the string to
NFC_LLCP_MAX_SERVICE_NAME.
