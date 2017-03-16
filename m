From: Kaiwen Xu <kaiwen.xu@hulu.com>
Subject: Re: [PATCH] [PATCH net] net: Do not hold the reference for the same
 sk_rx_dst.
Date: Thu, 16 Mar 2017 11:18:39 -0700
Message-ID: <20170316181839.GA61894@kevinmbp.test.hulu.com>
References: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>
 <87h92tv8uv.fsf@redhat.com>
 <242C9F89-8639-4C31-B3E5-B56C4F785E41@hulu.com>
 <87fuidv6ts.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jakub Sitnicki <jkbs@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0117.outbound.protection.outlook.com ([104.47.42.117]:24574
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752935AbdCPSSr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 14:18:47 -0400
Content-Disposition: inline
In-Reply-To: <87fuidv6ts.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 11:45:03AM +0100, Jakub Sitnicki wrote:
> On Thu, Mar 16, 2017 at 10:12 AM GMT, Kevin Xu wrote:
> > Do you mean the message looping endlessly?
> 
> No, the message is emitted just once. Around 100 seconds after
> destroying a few namespaces. Occurs not so often, maybe once per ten
> runs.
> 
> -Jakub
> 

I saw that happening from time to time during my test as well, I suspect
it was because some TCP sockets stays in either TCP_TIME_WAIT or
TCP_FIN_WAIT1. But eventually those sockets get destroyed and lo gets
deleted as well.

The patch was fixing an issue I am seeing, that the message gets looped
forever, and causing a deadlock on new network ns creation.

Kevin

> > If so, then I suppose it's a different bug.
> >
> > Kevin
> >
> >> On Mar 16, 2017, at 3:01 AM, Jakub Sitnicki <jkbs@redhat.com> wrote:
> >>
> >>> On Thu, Mar 16, 2017 at 08:08 AM GMT, Kevin Xu wrote:
> >>> In some rare cases, inet_sk_rx_dst_set() may be called multiple times
> >>> on the same dst, causing reference count leakage. Eventually, it
> >>> prevents net_device to be destroyed. The bug then manifested as
> >>>
> >>> unregister_netdevice: waiting for lo to become free. Usage count = 1
> >>>
> >>> in the kernel log, preventing new network namespace creation.
> >>>
> >>> The patch works around the issue by checking whether the socket already
> >>> has the same dst set.
> >>>
> >>> Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>
> >>> ---
> >>
> >> FWIW, with this patch applied I'm still sometimes seeing:
> >>
> >> [  125.928095] unregister_netdevice: waiting for lo to become free. Usage count = 1
> >>
> >> -Jakub
