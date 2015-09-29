From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net 3/7] openvswitch: Fix skb leak in ovs_fragment()
Date: Tue, 29 Sep 2015 16:12:57 -0700
Message-ID: <CANr6G5wNY592O_9bzH7Ok6-OT63odsNWOs0uusLzihEBw0-FTQ@mail.gmail.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
 <1443566380-22640-4-git-send-email-joestringer@nicira.com> <55E40A4D-8CE1-4433-9BB0-43CB41021BA1@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:35252 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbbI2XNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:13:17 -0400
Received: by ykdz138 with SMTP id z138so22946116ykd.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 16:13:17 -0700 (PDT)
In-Reply-To: <55E40A4D-8CE1-4433-9BB0-43CB41021BA1@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29 September 2015 at 15:48, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
>> On Sep 29, 2015, at 3:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
>>
>> @@ -728,8 +727,14 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
>>               WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
>>                         ovs_vport_name(vport), ntohs(ethertype), mru,
>>                         vport->dev->mtu);
>> -             kfree_skb(skb);
>> +             goto out;
>>       }
>> +
>> +     skb = NULL;
>> +
>> +out:
>> +     if (skb)
>> +             kfree_skb(skb);
>> }
>>
>> static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
>
> Wouldn't that hunk be better as:
>
> @@ -728,8 +727,13 @@ static void ovs_fragment(struct vport *vport, struct sk_buff *skb, u16 mru,
>                 WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
>                           ovs_vport_name(vport), ntohs(ethertype), mru,
>                           vport->dev->mtu);
> -               kfree_skb(skb);
> +               goto out;
>         }
> +
> +       return;
> +
> +out:
> +       kfree_skb(skb);
> }
>
> static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
>
> --
> Mark Rustad, Networking Division, Intel Corporation

Sure thing, I'll roll this change in to a v2 when the rest of the
series is reviewed.
