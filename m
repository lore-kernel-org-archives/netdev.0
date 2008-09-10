From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: [RFC] Control Group Classifier
Date: Wed, 10 Sep 2008 10:58:08 -0700
Message-ID: <166fe7950809101058r1183b2adk7dc369abae01f16d@mail.gmail.com>
References: <20080908115101.GE20815@postel.suug.ch>
	 <166fe7950809081428k2e1ba24crd54e66aa027f9998@mail.gmail.com>
	 <20080909000627.GF20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Paul Menage" <menage@google.com>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:60782 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbYIJR6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 13:58:21 -0400
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id m8AHwAd8004026
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 18:58:10 +0100
Received: from rv-out-0708.google.com (rvbk29.prod.google.com [10.140.87.29])
	by spaceape9.eur.corp.google.com with ESMTP id m8AHw8Ff017115
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 10:58:09 -0700
Received: by rv-out-0708.google.com with SMTP id k29so2458711rvb.0
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 10:58:08 -0700 (PDT)
In-Reply-To: <20080909000627.GF20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 8, 2008 at 5:06 PM, Thomas Graf <tgraf@suug.ch> wrote:
> * Ranjit Manomohan <ranjitm@google.com> 2008-09-08 14:28
>> Wouldn't this cause a lot of packets (like acks)  to be incorrectly
>> classifed to the current tasks cgroup although it may not have
>> anything to do with them? That is the reason I chose to put the
>> classid into the socket at creation time.
>
> In its current form, it does not work if the packet is rescheduled
> or not sent in the context of a process. Such packets simply end
> up not being classified at all. In the most common case, the packet
> is not queued before it hits the qdisc so this takes away a lot of
> complexity and is very fast but should still be sufficient.
>
> Alternatively I also thought about doing a socket lookup in the
> classifier (if !skb->sk) and store the classid in the socket. This
> would add more flexibility and work for ingress traffic whitout
> adding pollution to the sk_buff. It adds a heavy operation to the
> classification process though as it would probably require a lock.
>

Not clear to me why would it need a lock (for transmit)?  The skbuff
holds a reference to the socket so it should be safe to access without
any additional overhead. I have resent my patchset which does exactly
this. Besides like you mentioned you need it anyway for inbound packet
classification.

Our current internal implementation for inbound handling is:

Use the ingress qdisc to match all packets and perform an additional
action of looking up their socket for the cgroup classid and redirect
all packets to the ifb device. The same cgroups classifier can then be
used there to limit inbound traffic.

The only added complication here is that the new action will have to
do a socket lookup which requires simple helpers from the registered
protocols like TCP.

I shall send out the patches for this shortly.

-Thanks,
Ranjit
