From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 11/18] switchdev: remove old netdev_switch_port_bridge_setlink
Date: Mon, 30 Mar 2015 17:44:03 -0700
Message-ID: <CAE4R7bCrkheGf-7V_DnJyzFv73BQ0NpdD7khZL0y7NbSVzdhrg@mail.gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
	<1427704836-8776-12-git-send-email-sfeldma@gmail.com>
	<55194E63.5010100@cumulusnetworks.com>
	<CAE4R7bBWby3tDdzV+Hwvc_bzB3E-zNoHUQUX8OfF205Vyw-77g@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC35067FA7D3@ORSMSX101.amr.corp.intel.com>
	<CAE4R7bA4t-5P58jeK1NVAzM1fdk72o9UJRD8w+ByxKAtbp7b8A@mail.gmail.com>
	<E4CD12F19ABA0C4D8729E087A761DC35067FA9F0@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	=?UTF-8?B?Smlyw60gUMOtcmtv?= <jiri@resnulli.us>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:34993 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbbCaAoE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 20:44:04 -0400
Received: by obcjt1 with SMTP id jt1so3250135obc.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 17:44:03 -0700 (PDT)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC35067FA9F0@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 5:08 PM, Arad, Ronen <ronen.arad@intel.com> wro=
te:
>
>
>>-----Original Message-----
>>From: Scott Feldman [mailto:sfeldma@gmail.com]
>>Sent: Monday, March 30, 2015 2:28 PM
>>To: Arad, Ronen
>>Cc: roopa; Netdev; Jir=C3=AD P=C3=ADrko; Guenter Roeck; Florian Faine=
lli
>>Subject: Re: [PATCH net-next 11/18] switchdev: remove old
>>netdev_switch_port_bridge_setlink
>>
>>On Mon, Mar 30, 2015 at 1:46 PM, Arad, Ronen <ronen.arad@intel.com> w=
rote:
>>>
>>>
>>>>-----Original Message-----
>>>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel=
=2Eorg] On
>>>>Behalf Of Scott Feldman
>>>>Sent: Monday, March 30, 2015 1:20 PM
>>>>To: roopa
>>>>Cc: Netdev; Ji=C5=99=C3=AD P=C3=ADrko; Guenter Roeck; Florian Faine=
lli
>>>>Subject: Re: [PATCH net-next 11/18] switchdev: remove old
>>>>netdev_switch_port_bridge_setlink
>>>>
>>>>On Mon, Mar 30, 2015 at 6:23 AM, roopa <roopa@cumulusnetworks.com> =
wrote:
>>>>> On 3/30/15, 1:40 AM, sfeldma@gmail.com wrote:
>>>>>>
>>>>>> From: Scott Feldman <sfeldma@gmail.com>
>>>>>>
>>>>>> New attr-based bridge_setlink can recurse lower devs and recover=
 on err,
>>>>>> so
>>>>>> remove old wrapper.  Also, restore br_setlink back to original a=
nd don't
>>>>>> call
>>>>>> into SELF port driver.  rtnetlink.c:bridge_setlink already does =
a call
>>>>>> into
>>>>>> port driver for SELF.
>>>>>>
>>>>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>>>>
>>>>> removing this now requires every vlan add to be a two step proces=
s, why ?
>>>>
>>>>No, that's not true.  You want to use
>>>>ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid in your port driver, and t=
hen
>>>>using either vlan driver standalone or the bridge driver vlan suppo=
rt
>>>>will work.
>>>>
>>>>Try it.  Implement ndo_vlan_rx_add_vid in your port driver and veri=
fy
>>>>you get called to add VLAN to port with either:
>>>>
>>>>    bridge vlan add dev swp1 vid 10
>>>>
>>>>    -or-
>>>>
>>>>    vconfig add swp1 10
>>>>
>>>>Same for deleting a VLAN, either of these two commands call into th=
e
>>>>port driver ndo_vlan_rx_kill_vid:
>>>>
>>>>    bridge vlan del dev swp1 vid 10
>>>>
>>>>    -or-
>>>>
>>>>    vconfig rem swp1 10
>>>>
>>>>
>>>>> bridge vlan add dev swp1 vid 10
>>>>> bridge vlan add dev swp1 vid 10 self
>>>>
>>>>Not necessary.  The first command is sufficient if using
>>>>ndo_vlan_rx_add_vid.
>>>
>>> This is not sufficient for VLAN filtering. Ndo_vlan_rx_add_vid does=
 not
>>> provide the vinfo flags PVID and UNTAGGED. Therefore it is not
>>> an adequate replacement for propagating setlink/dellink messages to=
 the
>>> swithport driver or an alternative via swdev_attr.
>>
>>Glad you bring that point up.  I think these can get cast as port
>>attrs and set using swdev_attr.  This is something swdev attr should
>>open up is allowing more settings to be pushed down to port driver.
>>I'll look into this one and include it with v2.
>
> It could be beneficial to build extensibility into swdev_attr.
> An experimenter attribute designed to carry arbitrary data could allo=
w
> for passing new attributes and implementation specific attributes
> without affecting any existing switchdev driver:
>
> enum swdev_attr_id {
>         SWDEV_ATTR_UNDEFINED,
>         SWDEV_ATTR_EXPERIMENTER,
>         SWDEV_ATTR_PORT_PARENT_ID,
>         SWDEV_ATTR_PORT_STP_STATE,
>  };
>
>
> struct swdev_experimenter_attr {
>         u32 exp_id;     /* - MSB 0: low-order bytes are IEEE OUI */
>                         /* - MSB !=3D 0: reserved for netdev */
>         u32 exp_attr;
>         u16 exp_attr_size;
>         const void *exp_attr_data;
> }
>
> struct swdev_attr {
>         enum swdev_attr_id attr;
>         u32 flags;
>
>         union {
>                 struct netdev_phys_item_id ppid;        /* PORT_PAREN=
T_ID */
>                 u8 stp_state;                           /* PORT_STP_S=
TATE */
>                 unsigned long brport_flags;     /* PORT_BRIDGE_FLAGS =
*/
>                 /* netdev defined attributes abobe this line */
>                 struct swdev_experimenter_attr exp_attr;
>         };

I'm scared of void *'s.  How would this be used?  Maybe an example to
illustrate the use-case would help.
