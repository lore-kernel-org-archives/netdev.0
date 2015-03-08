From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 2/8] netdevice: add IPv4 fib add/del ops
Date: Sun, 08 Mar 2015 07:31:50 -0700
Message-ID: <54FC5D56.3090702@cumulusnetworks.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com> <1425619280-27492-3-git-send-email-sfeldma@gmail.com> <54F9BFCB.5030100@mojatatu.com> <CAE4R7bAcfJ8M0eQMdZdS3aDgPVWSQznABZymGq+PU34vJx1suA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34863 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbbCHObv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 10:31:51 -0400
Received: by pdbfp1 with SMTP id fp1so37450694pdb.2
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 07:31:51 -0700 (PDT)
In-Reply-To: <CAE4R7bAcfJ8M0eQMdZdS3aDgPVWSQznABZymGq+PU34vJx1suA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/6/15, 11:59 AM, Scott Feldman wrote:
>
> I considered passing netlink flags in to driver, but the kernel logic
> in fib_table_insert() already takes care of the checks required by the
> flags, and from the driver's perspective, only three ops are needed:
> add, del, and mod.  And I've combined add and mod into the same op,
> with the assumption the driver can know if an entry exists or not.
>
> Can it work?
>
> Let's try the various user cmds and see what happens:
>
> ip route add ...             CREATE|EXCL
>
>      if kernel FIB entry exists
>          return -EEXIST to user
>      else
>          call driver add op
>          add kernel FIB entry
>
> ip route change ...        REPLACE
>
>      if kernel FIB entry exists
>          call driver add op             // driver treats this as a mod
>          modify kernel FIB entry
>      else
>          return -ENOENT
>
> ip route replace ...         CREATE|REPLACE
>
>      if kernel FIB entry exists
>           call driver add op             // driver treats this as a mod
>           modify kernel FIB entry
>      else
>          call driver add op
>          add kernel FIB entry
>
> ip route prepend ...        CREATE
>
>      if kernel FIB entry exists
>           call driver add op             // driver treats this as a mod
>           prepend kernel FIB entry
>      else
>          call driver add op
>          add kernel FIB entry
>
> ip route append ...          CREATE|APPEND
>
>      if kernel FIB entry exists
>           call driver add op             // driver treats this as a mod
>           append kernel FIB entry
>      else
>          call driver add op
>          add kernel FIB entry
>
>
> I'm not 100% on the prepend/append cases.  Maybe don't try to offload
> prepend/append cases?
We will have to offload prepend/append cases as well (I had also raised 
this earlier in v2).
  And, I dont see a problem passing the flags to the driver in the ndo op.

Thanks,
Roopa
