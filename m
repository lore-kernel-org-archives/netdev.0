From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net v4] rtnl/bond: don't send rtnl msg for unregistered iface
Date: Mon, 13 Jul 2015 16:11:14 +0200
Message-ID: <CAKfDRXjM-afW=PD77KSWU3AKk3ow_zUwb5KW3c3pSYDyAuCjqQ@mail.gmail.com>
References: <20150512161402.GC2081@nanopsycho>
	<1431519582-4219-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jiri@resnulli.us, David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:33671 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbbGMOLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 10:11:16 -0400
Received: by laem6 with SMTP id m6so9934198lae.0
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 07:11:14 -0700 (PDT)
In-Reply-To: <1431519582-4219-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a quick question about this patch.

On Wed, May 13, 2015 at 2:19 PM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 837d30b5ffed..7b25f1ef3d75 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2415,6 +2415,9 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
>  {
>         struct sk_buff *skb;
>
> +       if (dev->reg_state != NETREG_REGISTERED)
> +               return;
> +

Is this check correct, or placed at the correct location? The reason I
am asking is as follows. In rollback_registered_many(), dev->reg_state
is set to NETREG_UNREGISTERING for devices that will be unregistered.
When rtmsg_ifinfo_build_skb(RTM_DELLINK, ...) is called in the
following loop in rollback_registered_many, this comparison will
always be true and no DELLINK event generated.

This change led to some applications I have not behaving as expected
due to missing DELLINK when network devices are removed. I also see no
DELLINK with ip mon link. Removing the check restores the old behavior
(DELLINK events are generated). My machine is running 3.18.18, which
includes this fix.

Thanks in advance for any help,
Kristian
