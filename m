From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on
 stacked netdevices
Date: Sun, 15 Mar 2015 20:17:22 +0100
Message-ID: <20150315191722.GE3518@nanopsycho.orion>
References: <1426206598-29410-1-git-send-email-roopa@cumulusnetworks.com>
 <20150313.001007.65274068513753002.davem@davemloft.net>
 <5502E544.7030003@cumulusnetworks.com>
 <20150313.123156.2118585119289960334.davem@davemloft.net>
 <CAE4R7bCvFPE5nPBJ7r41-ZC6=5AUE=gQ7uTy4kTNTZf-xKraVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35503 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbbCOTR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:17:26 -0400
Received: by wibdy8 with SMTP id dy8so22613713wib.0
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 12:17:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bCvFPE5nPBJ7r41-ZC6=5AUE=gQ7uTy4kTNTZf-xKraVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 15, 2015 at 07:08:02PM CET, sfeldma@gmail.com wrote:
>On Fri, Mar 13, 2015 at 9:31 AM, David Miller <davem@davemloft.net> wrote:
>> From: roopa <roopa@cumulusnetworks.com>
>> Date: Fri, 13 Mar 2015 06:25:24 -0700
>>
>>> David, if you mean not touch bond and team but have the switchdev
>>> api do it transparently, yes, i had it that way initially.  And i do
>>> liked it that way as well. But the feedback i received (during the
>>> initial introduction of this for setlink/dellink) was to make it
>>> explicit for each master.
>>
>> I think the concern is that we only want to do this for devices
>> for which it is safe to "traverse" down like this.
>>
>> But frankly I cannot think of any layered device where we would
>> not want to do this.
>>
>> Let's go back to the simple scheme where we unconditionally traverse
>> and if we hit a problem case we'll figure out how to deal with it
>> then, ok?
>
>Here's a way to do it without touching team/bonding/vlan drivers, but
>also giving us flexibility to down the road to intercept the call in
>the team/bonding/vlan driver and change the behavior by implementing
>swdev_port_stp_update in the middle driver.
>
>I would prefer this approach not only for STP updates but also for
>port attr set/get calls.
>
>
>/**
> *      netdev_switch_port_stp_update - Notify switch device port of STP
> *                                      state change
> *      @dev: bridge port device
> *      @state: bridge port STP state
> *
> *      Notify switch device port of bridge port STP state change.
> */
>int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>{
>        const struct swdev_ops *ops = dev->swdev_ops;
>        struct net_device *lower_dev;
>        struct list_head *iter;
>        int err = -EOPNOTSUPP;
>
>        if (ops && ops->swdev_port_stp_update)
>                return ops->swdev_port_stp_update(dev, state);
>
>        /* Bridged switch device port(s) may be stacked under
>         * bond/team/vlan dev, so recurse down to stp-update
>         * them one at a time.
>         */
>
>        netdev_for_each_lower_dev(dev, lower_dev, iter) {
>                err = netdev_switch_port_stp_update(lower_dev, state);
>                if (err && err != -EOPNOTSUPP)
>                        return err;
>        }


I don't like this blind approach. Note that with this, you enable this
for lower devices of:
bond
ipvlan
macvlan
team
vlan
batman-adv

Does that make sense? I think it is better just pick what we want to
support now and implement it there. That makes things clearer and
confusion-prone.

Jiri
