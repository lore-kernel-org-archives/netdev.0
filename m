From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: Information leak in llcp_sock_bind/llcp_raw_sock_bind
Date: Tue, 15 Dec 2015 21:55:37 +0100
Message-ID: <CACT4Y+a804iMbkA+kWdYfOPYGQz61ZCRVqKOdDBYtSM=FQ2cYQ@mail.gmail.com>
References: <CACT4Y+bjSFyXZi1PKTUsT9PhAYvCGiGjRkOBRbUON0Pw7rJxGg@mail.gmail.com>
 <20151215.153626.1500179484827859040.davem@davemloft.net> <CACT4Y+ZnZ2EcZwc6T5LZ1YR2zC8+6aFT_JFYb_LeegnB6tmESw@mail.gmail.com>
 <20151215.154851.2132284113916223057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151215.154851.2132284113916223057.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2015 at 9:48 PM, David Miller <davem@davemloft.net> wrote:
> From: Dmitry Vyukov <dvyukov@google.com>
> Date: Tue, 15 Dec 2015 21:45:16 +0100
>
>> On Tue, Dec 15, 2015 at 9:36 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Dmitry Vyukov <dvyukov@google.com>
>>> Date: Tue, 15 Dec 2015 21:00:20 +0100
>>>
>>>> The problem is that llcp_sock_bind/llcp_raw_sock_bind do not check
>>>> sockaddr_len passed in, so they copy stack garbage from stack into the
>>>> socket and then return it in getsockname.
>>>> This can defeat ASLR, leak crypto keys, etc.
>>>
>>> That's actually the first thing these functions do.
>>>
>>> They completely clear out the on-stack llcp_addr, then they copy only
>>> as much as the user gave them, being careful not to use more than
>>> sizeof(llcp_addr).
>>>
>>>         memset(&llcp_addr, 0, sizeof(llcp_addr));
>>>         len = min_t(unsigned int, sizeof(llcp_addr), alen);
>>>         memcpy(&llcp_addr, addr, len);
>>>
>>> I don't see what the problem is, you'll need to be more specific.
>>
>> You are right. Sorry.
>>
>> There still seems to be a minor leak here:
>>
>>   if (!addr || addr->sa_family != AF_NFC)
>>       return -EINVAL;
>>
>> addr->sa_family can be uninit.
>
> That shouldn't matter at all, that can't cause socket state corruption.
>
> I want to ask you if you are actually seeing kernel stack in that hexdump
> you are posting?  If so, how do you actually account for it?  Nothing you
> have shown so far make that clear.

I've seen a kernel address at least in pptp_bind, it was a return pc
in SyS_socket call that was executed just before bind.
Exact contents of the leaked info depend on kernel config, compiler
and a previous executed syscall (there are thousands of them if we
count ioctls and friends). So it is almost impossible to prove that a
PC cannot be leaked.
