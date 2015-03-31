From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v1] bonding: Fix another case of LACPDU not sent
 on slave
Date: Tue, 31 Mar 2015 10:13:09 -0700
Message-ID: <CAF2d9jhgdkV7QuDdKC3v1OG5Kvrr80XCpy-F8ZDbaYHMbrnosw@mail.gmail.com>
References: <1427751076-4512-1-git-send-email-maheshb@google.com> <20150331155956.GP1051@gospo>
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
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35992 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554AbbCaRNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:13:42 -0400
Received: by obbec2 with SMTP id ec2so36483321obb.3
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 10:13:42 -0700 (PDT)
In-Reply-To: <20150331155956.GP1051@gospo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2015 at 8:59 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Mon, Mar 30, 2015 at 02:31:16PM -0700, Mahesh Bandewar wrote:
>> When mii-mon discovers that the link is up, it will call
>> bond_3ad_handle_link_change() but we forget to add the LACP_ENABLED
>> flag when we discover the speed and duplex for the slave link are
>> normal.
>>
>> Change-Id: Ie8b268ecfeea0f99bf9fdcd72706c0653f9d9e49
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>
> This won't make the state machine start-up more quickly will it?  Either
> way...
>
I'm seeing some occasions where LACP state for a port is in weird
state. The port has correct speed and duplex but there are no LACPDUs
are exchanged with partner. Seems like there is some sort of race
condition in the code and trying to hunt that down.

This definitely looks like a place where it would happen since miimon
will detect and update the speed and duplex for the port but lack of
ENABLE_LACP flag will prevent state-machine from sending LACPDU. This
is especially a big problem when the partner is in passive mode! This
takes port out of the active aggregation group so unless there is
another link-event on this port, it will not join the aggregator
again.

So the idea behind this patch is not to expedite the state-machine run
but to make it correctly.

> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>
>
>> ---
>>  drivers/net/bonding/bond_3ad.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index 4309b5a76708..30e8d118664b 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -2436,12 +2436,15 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
>>               port->actor_admin_port_key &= ~AD_SPEED_KEY_MASKS;
>>               port->actor_oper_port_key = port->actor_admin_port_key |=
>>                       (__get_link_speed(port) << 1);
>> +             if (port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS)
>> +                     port->sm_vars |= AD_PORT_LACP_ENABLED;
>>       } else {
>>               /* link has failed */
>>               port->is_enabled = false;
>>               port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
>>               port->actor_oper_port_key = (port->actor_admin_port_key &=
>>                                            ~AD_SPEED_KEY_MASKS);
>> +             port->sm_vars &= ~AD_PORT_LACP_ENABLED;
>>       }
>>       netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
>>                  port->actor_port_number,
>> --
>> 2.2.0.rc0.207.ga3a616c
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
