From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: eBPF: how to check the flow table
Date: Mon, 19 Sep 2016 10:53:08 -0700
Message-ID: <20160919175306.GA81218@ast-mbp.thefacebook.com>
References: <1474200135.19872.12.camel@regit.org>
 <1474268215.32028.1.camel@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: Eric Leblond <eric@regit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36686 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751008AbcISRxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 13:53:14 -0400
Received: by mail-pf0-f181.google.com with SMTP id q2so33068358pfj.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 10:53:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1474268215.32028.1.camel@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 08:56:55AM +0200, Eric Leblond wrote:
> Hello,
> 
> On Sun, 2016-09-18 at 14:02 +0200, Eric Leblond wrote:
> > Hello,
> > 
> > I'm currently testing a code implementing AF_PACKET bypass for
> > Suricata. The idea is that Suricata is updating a hash table
> > containing
> > a list of flows it does not want to see anymore.
> > 
> > I want to check flow timeout from the userspace, so my current
> > algorithm is doing:
> > 
> >     while (bpf_get_next_key(mapfd, &key, &next_key) == 0) {
> >         bpf_lookup_elem(mapfd, &next_key, &value);
> >         FlowCallback(mapfd, &next_key, &value, data);
> >         key = next_key;
> >     }
> > 
> > In the FlowCallback, I check the timing in the flow entry and I
> > remove
> > the key if the flow is timeout.
> > 
> > This is currently working well when there is only a few flows but on
> > a
> > real system with log of insertion in the table, the loop is never
> > returning because we dequeue slower than we enqueue.
> > 
> > Is there a better algorithm or an other way to do it ? 
> 
> It seems I missed an obvious race condition in my existing code. I'll
> continue to test and relive this thread if necessary.

On tracing side we do similar loops all the time.
yes they're racy by design, since kernel always have to proceed.
User space have to be more careful with iteration over the map
to make sure that get_next actually moves forward.
It's indeed possible to custom craft a situation where user space
will forever loop.
Here is one:
https://github.com/iovisor/bcc/issues/665
