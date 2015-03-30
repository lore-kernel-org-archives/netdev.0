From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next] bonding: BOND_MONITOR_CHURNED is a port variable
Date: Mon, 30 Mar 2015 10:44:48 -0700
Message-ID: <CAF2d9jgSM=1dy5vnvTzK+SvbzdNtVvd6SAUpUJaJgqLo7ef9Eg@mail.gmail.com>
References: <1427519893-19304-1-git-send-email-maheshb@google.com>
 <20150330152638.GL1051@gospo> <CAF2d9jiVf-9yqpk5+2XxQqwSXmesg1N-NWyEqb-5WFV6vmAAgA@mail.gmail.com>
 <20150330171731.GM1051@gospo>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33627 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbbC3RpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 13:45:09 -0400
Received: by obvd1 with SMTP id d1so66308532obv.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 10:45:09 -0700 (PDT)
In-Reply-To: <20150330171731.GM1051@gospo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 10:17 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Mon, Mar 30, 2015 at 09:37:45AM -0700, Mahesh Bandewar wrote:
>> On Mon, Mar 30, 2015 at 8:26 AM, Andy Gospodarek
>> <gospo@cumulusnetworks.com> wrote:
>> > On Fri, Mar 27, 2015 at 10:18:13PM -0700, Mahesh Bandewar wrote:
>> >> It's a trivial change to assign the correct value for this Churn-machine
>> >> state. This is actually a port variable and hence assigning some arbitrary
>> >> value might be error prone.
>> >
>> > I am looking at 802.1AX-2008 and I do not see this value defined in
>> > 5.4.8 ("Variables used for managing the operation of the state
>> > machines").  What specification were you looking at that had a 'port
>> > churned' (or similar) state mentioned?
>> >
>> It's a combination of "actor_churn" + "partner_churn". Since the
>> verbose form AD_PORT_ACTOR_PARTNER_CHURNED would be long, decided to
>> shorten it.
>
> I agree with that the shorter name is better.  Good call there.
>
> If we are just checking to see if either AD_PORT_ACTOR_CHURN or
> AD_PORT_PARTNER_CHURN why not just change AD_PORT_CHURNED to be equal to
> the previous defines?
>
> @@ -71,6 +70,7 @@
>  #define AD_PORT_STANDBY         0x80
>  #define AD_PORT_SELECTED        0x100
>  #define AD_PORT_MOVED           0x200
> +#define AD_PORT_CHURNED         (AD_PORT_ACTOR_CHURN|AD_PORT_PARTNER_CHURN)
>
Yes, makes sense.

>  /* Port Key definitions
>   * key is determined according to the link speed, duplex and
>
> or just set the existing bits and add an inline function or macro to
> check in ad_churn_machine() since that is the only place being checked?
>
> If seems like the bits already there represent what you want, so it
> seems reasonable to use them rather than creating something extra that
> is not included in the spec.
>
sure, will send v2 with this update.
>>
>>
>> If we consider churn-machine-state as part of the LACP state machine,
>> >>
>> >> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> >> ---
>> >>  drivers/net/bonding/bond_3ad.c | 12 ++++++------
>> >>  1 file changed, 6 insertions(+), 6 deletions(-)
>> >>
>> >> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> >> index b8444746521f..3cce25818b57 100644
>> >> --- a/drivers/net/bonding/bond_3ad.c
>> >> +++ b/drivers/net/bonding/bond_3ad.c
>> >> @@ -38,7 +38,6 @@
>> >>  #define AD_STANDBY                 0x2
>> >>  #define AD_MAX_TX_IN_SECOND        3
>> >>  #define AD_COLLECTOR_MAX_DELAY     0
>> >> -#define AD_MONITOR_CHURNED         0x1000
>> >>
>> >>  /* Timer definitions (43.4.4 in the 802.3ad standard) */
>> >>  #define AD_FAST_PERIODIC_TIME      1
>> >> @@ -71,6 +70,7 @@
>> >>  #define AD_PORT_STANDBY         0x80
>> >>  #define AD_PORT_SELECTED        0x100
>> >>  #define AD_PORT_MOVED           0x200
>> >> +#define AD_PORT_CHURNED         0x400
>> >>
>> >>  /* Port Key definitions
>> >>   * key is determined according to the link speed, duplex and
>> >> @@ -1016,7 +1016,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>> >>       /* first, check if port was reinitialized */
>> >>       if (port->sm_vars & AD_PORT_BEGIN) {
>> >>               port->sm_rx_state = AD_RX_INITIALIZE;
>> >> -             port->sm_vars |= AD_MONITOR_CHURNED;
>> >> +             port->sm_vars |= AD_PORT_CHURNED;
>> >>       /* check if port is not enabled */
>> >>       } else if (!(port->sm_vars & AD_PORT_BEGIN)
>> >>                && !port->is_enabled && !(port->sm_vars & AD_PORT_MOVED))
>> >> @@ -1026,7 +1026,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>> >>                (port->sm_rx_state == AD_RX_DEFAULTED) ||
>> >>                (port->sm_rx_state == AD_RX_CURRENT))) {
>> >>               if (port->sm_rx_state != AD_RX_CURRENT)
>> >> -                     port->sm_vars |= AD_MONITOR_CHURNED;
>> >> +                     port->sm_vars |= AD_PORT_CHURNED;
>> >>               port->sm_rx_timer_counter = 0;
>> >>               port->sm_rx_state = AD_RX_CURRENT;
>> >>       } else {
>> >> @@ -1108,7 +1108,7 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>> >>                       port->partner_oper.port_state |= AD_STATE_LACP_ACTIVITY;
>> >>                       port->sm_rx_timer_counter = __ad_timer_to_ticks(AD_CURRENT_WHILE_TIMER, (u16)(AD_SHORT_TIMEOUT));
>> >>                       port->actor_oper_port_state |= AD_STATE_EXPIRED;
>> >> -                     port->sm_vars |= AD_MONITOR_CHURNED;
>> >> +                     port->sm_vars |= AD_PORT_CHURNED;
>> >>                       break;
>> >>               case AD_RX_DEFAULTED:
>> >>                       __update_default_selected(port);
>> >> @@ -1144,8 +1144,8 @@ static void ad_rx_machine(struct lacpdu *lacpdu, struct port *port)
>> >>   */
>> >>  static void ad_churn_machine(struct port *port)
>> >>  {
>> >> -     if (port->sm_vars & AD_MONITOR_CHURNED) {
>> >> -             port->sm_vars &= ~AD_MONITOR_CHURNED;
>> >> +     if (port->sm_vars & AD_PORT_CHURNED) {
>> >> +             port->sm_vars &= ~AD_PORT_CHURNED;
>> >>               port->sm_churn_actor_state = AD_CHURN_MONITOR;
>> >>               port->sm_churn_partner_state = AD_CHURN_MONITOR;
>> >>               port->sm_churn_actor_timer_counter =
>> >> --
>> >> 2.2.0.rc0.207.ga3a616c
>> >>
>> >> --
>> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> >> the body of a message to majordomo@vger.kernel.org
>> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
