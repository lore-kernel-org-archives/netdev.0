From: Julien Gomes <julien@arista.com>
Subject: Re: [PATCH net-next 1/2] ipmr: restrict mroute "queue full" warning
 to related error values
Date: Fri, 23 Jun 2017 13:17:31 -0700
Message-ID: <ef5f803e-d9ac-e0da-0443-d7b6c68d0fd0@arista.com>
References: <20170621175811.16940-1-julien@arista.com>
 <20170623.133947.433422648753848462.davem@davemloft.net>
 <bc8a9605-2df7-821f-5103-e9acb4482f3a@arista.com>
 <20170623.144739.1791220360024944932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170623.144739.1791220360024944932.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/23/2017 11:47 AM, David Miller wrote:

> From: Julien Gomes <julien@arista.com>
> Date: Fri, 23 Jun 2017 10:52:26 -0700
>
>> On 06/23/2017 10:39 AM, David Miller wrote:
>>
>>> From: Julien Gomes <julien@arista.com>
>>> Date: Wed, 21 Jun 2017 10:58:10 -0700
>>>
>>>> When sending a cache report on mroute_sk, mroute will emit a
>>>> "pending queue full" warning for every error value returned by
>>>> sock_queue_rcv_skb().
>>>> This warning can be misleading, for example on the EPERM error value
>>>> that sk_filter() can return.
>>>>
>>>> Restricting this warning to only ENOMEM or ENOBUFS seems more
>>>> appropriate.
>>>>
>>>> Signed-off-by: Julien Gomes <julien@arista.com>
>>> Incorrect, no other error codes are possible.
>>>
>>> We never attach a socket filter to these kernel internal sockets,
>>> therefore sk_filter() is not even applicable in this analysis.
>>>
>>> Therefore, -ENOBUFS and -ENOMEM are the only errors we can ever see
>>> returned from sock_queue_rcv_skb().
>>>
>>> This goes for your second patch as well.
>> Up to now I would agree, but now that cache reports are also sent
>> through Netlink, wouldn't it make sense to allow the user of mroute_sk
>> to attach a filter to it in order to not receive cache reports on it?
> There is not visibility of this socket outside of the kernel.

Hmm, maybe we are not talking about the same thing.

The value of this socket pointer is set by the MRT_INIT sockopt.
The socket is definitely visible outside of the kernel as it is first
created and used by the user for kernel-user communications
via the sockopts and the messages sent by the kernel to the user
through it.


The typical user setup up to now was to create this socket,
MRT_INIT to register it in ipmr, and handle the incoming packets,
including the cache reports.

Now that the cache reports are also sent through another medium,
the user should be able to decide whether it also wants the
reports on this socket, which, once again, it is already using.
And if the user wants to get the reports only through Netlink,
the kernel will currently emit those unrelated warnings.

Once again, we are not in the case of a purely internal kernel socket,
as this socket is used for internal kernel-user communications.

-- 
Julien Gomes
