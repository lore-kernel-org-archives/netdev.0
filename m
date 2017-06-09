From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: Add sockaddr length checks before accessing
 sa_family in bind and connect handlers
Date: Fri, 09 Jun 2017 10:09:55 -0400 (EDT)
Message-ID: <20170609.100955.2159377473358085139.davem@davemloft.net>
References: <20170608091336.8274-1-mjurczyk@google.com>
        <20170608.160425.3981801836671654.davem@davemloft.net>
        <CAPr8fOTtiUwBiVP2_740WZmmbbN=6oYJoyBCK31qOFbq5UCtSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
        viro@zeniv.linux.org.uk, keescook@chromium.org,
        mszeredi@redhat.com, iboukris@gmail.com, avagin@openvz.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mjurczyk@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPr8fOTtiUwBiVP2_740WZmmbbN=6oYJoyBCK31qOFbq5UCtSw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mateusz Jurczyk <mjurczyk@google.com>
Date: Fri, 9 Jun 2017 13:15:40 +0200

> On Thu, Jun 8, 2017 at 10:04 PM, David Miller <davem@davemloft.net> wrote:
>> From: Mateusz Jurczyk <mjurczyk@google.com>
>> Date: Thu,  8 Jun 2017 11:13:36 +0200
>>
>>> Verify that the caller-provided sockaddr structure is large enough to
>>> contain the sa_family field, before accessing it in bind() and connect()
>>> handlers of the AF_UNIX socket. Since neither syscall enforces a minimum
>>> size of the corresponding memory region, very short sockaddrs (zero or
>>> one byte long) result in operating on uninitialized memory while
>>> referencing .sa_family.
>>>
>>> Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
>>
>> The sockaddr comes from a structure on the caller's kernel stack, even
>> if the user gives a smaller length, it is legal to access that memory.
> 
> It is legal to access it, but since it's uninitialized kernel stack
> memory, the results of comparisons against AF_UNIX or AF_UNSPEC are
> indeterminate. In practice a user-mode program could likely use timing
> measurement to infer the evaluation of these comparisons, and hence
> determine if a garbage 16-bit variable on the kernel stack is equal to
> 0x0000 or 0x0001, or a garbage byte is equal to 0x00 (if the first
> byte is provided).
> 
> This is of course not very bad. However, my project for finding use of
> uninitialized memory flagged it, and I thought it was worth fixing, at
> least to avoid having this construct detected in the future (e.g. by
> KMSAN).
> 
> There are a few more instances of this behavior in other socket types,
> which I was going to report with separate patches. If you decide this
> kind of issues indeed deserves a fix, please let me know if further
> separate patches are the right approach.

Oh that's right, we don't zero initialize the on-stack object before
copying from userspace.

I'm going to apply this patch and please submit further changes fixing
bugs like this one.

Thanks.
