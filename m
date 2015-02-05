From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: Re: [ovs-dev] [PATCH] net: openvswitch: Support masked set actions.
Date: Thu, 5 Feb 2015 10:20:56 -0800
Message-ID: <14D3CD27-3B5C-4CC4-9EE7-5C79A2AAD303@nicira.com>
References: <1418170225-9328-1-git-send-email-jrajahalme@nicira.com> <CAEP_g=8vm3+028GVdh-4DidOzpgfNiNQB7T1OqJ-_jOdPNU5Dw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:41926 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750825AbbBESNs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 13:13:48 -0500
Received: by mail-pd0-f177.google.com with SMTP id g10so3066211pdj.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:13:48 -0800 (PST)
In-Reply-To: <CAEP_g=8vm3+028GVdh-4DidOzpgfNiNQB7T1OqJ-_jOdPNU5Dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for not remembering about these=85

On Dec 10, 2014, at 6:03 PM, Jesse Gross <jesse@nicira.com> wrote:

> On Tue, Dec 9, 2014 at 4:10 PM, Jarno Rajahalme <jrajahalme@nicira.co=
m> wrote:
>> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_n=
etlink.c
>> index df3c7f2..276bb60 100644
>> --- a/net/openvswitch/flow_netlink.c
>> +++ b/net/openvswitch/flow_netlink.c
>> @@ -2007,6 +2117,18 @@ int ovs_nla_put_actions(const struct nlattr *=
attr, int len, struct sk_buff *skb)
>>                                return err;
>>                        break;
>>=20
>> +               case OVS_ACTION_ATTR_SET_MASKED:
>> +                       err =3D masked_set_action_to_attr(a, skb);
>> +                       if (err)
>> +                               return err;
>> +                       break;
>=20
> I don't think this is necessary - the default case will handle things
> that don't need any special processing.
>=20

Right, the masked_set_action_to_attr() function is actually the same as=
 the default processing, so it can be removed. Thanks for pointing this=
 out!

> I think you can also remove the port checks in validate_tp_port()
> since the reasoning behind them is the same as the IP proto check.
>=20

The reasoning for removing the the IP proto check was that it may be wi=
ldcarded, and that we are checking for the presence of the IP header an=
yway when executing the check.

Same applies to the ports, in principle the flow could wildcard them an=
d a set action could set one or both of them regardless (even though th=
e current OVS userspace still exact matches all the fields it sets, but=
 this may change in the future).

=46or transport protocol we validate the flow for the right IP proto fi=
eld value, and in execution we use sib_make_writeable() to make sure th=
e packet actually has the space for the header, so we can safely drop t=
he flow key transport port checks from validate_tp_port(). All that rem=
ains there are the ethertype checks, which we need to keep as the ip.pr=
oto field is also used for the ARP opcode, which could collide with a v=
alid IPPROTO_ value. However, it seems strange to have a function named=
 validate_tp_ports() to only check that the ethertype is either IPv4 or=
 IPv6, so I will inline the checks to validate_set().

> Otherwise, I'm generally happy with this though.

I=92ll send a v3 later today.

Thanks,

  Jarno