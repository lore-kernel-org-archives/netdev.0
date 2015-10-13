From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 6/7] rocker: remove nowait from switchdev
 callbacks.
Date: Tue, 13 Oct 2015 08:25:30 +0200
Message-ID: <20151013062530.GE2242@nanopsycho.orion>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us>
 <1444672986-20709-1-git-send-email-jiri@resnulli.us>
 <1444672986-20709-5-git-send-email-jiri@resnulli.us>
 <CAE4R7bDfDCEGcHY=y+77DbC0z09ogN9jiO_qBhb+utwXTUzmHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33372 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbbJMGZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 02:25:33 -0400
Received: by wicge5 with SMTP id ge5so42556006wic.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 23:25:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bDfDCEGcHY=y+77DbC0z09ogN9jiO_qBhb+utwXTUzmHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 13, 2015 at 06:02:28AM CEST, sfeldma@gmail.com wrote:
>On Mon, Oct 12, 2015 at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> No need to avoid sleeping in switchdev callbacks now, as the switchdev
>> core allows it.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  drivers/net/ethernet/rocker/rocker.c | 7 +++----
>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>> index bb956a5..9629c5b5 100644
>> --- a/drivers/net/ethernet/rocker/rocker.c
>> +++ b/drivers/net/ethernet/rocker/rocker.c
>> @@ -3672,7 +3672,7 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
>>             rocker_port->stp_state == BR_STATE_FORWARDING)
>>                 return 0;
>>
>> -       flags |= ROCKER_OP_FLAG_REMOVE;
>> +       flags |= ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
>
>I understand the two changes below where you're removing NOWAIT, but
>here you're adding NOWAIT which I'm not sure how that is related to
>the switchdev core changes.  Is this two patches?

I removed ROCKER_OP_FLAG_NOWAIT from attr_set. But here in
rocker_port_fdb_flush, which is called from attr_set, we call
rocker_port_fdb_learn with spin lock. Therefore I had to put
ROCKER_OP_FLAG_NOWAIT here. Before ROCKER_OP_FLAG_NOWAIT removal from
attr_set this was there already.


>
>
>>         spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
>>
>> @@ -4382,8 +4382,7 @@ static int rocker_port_attr_set(struct net_device *dev,
>>
>>         switch (attr->id) {
>>         case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
>> -               err = rocker_port_stp_update(rocker_port, trans,
>> -                                            ROCKER_OP_FLAG_NOWAIT,
>> +               err = rocker_port_stp_update(rocker_port, trans, 0,
>>                                              attr->u.stp_state);
>>                 break;
>>         case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
>> @@ -4517,7 +4516,7 @@ static int rocker_port_fdb_del(struct rocker_port *rocker_port,
>>                                const struct switchdev_obj_port_fdb *fdb)
>>  {
>>         __be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
>> -       int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
>> +       int flags = ROCKER_OP_FLAG_REMOVE;
>>
>>         if (!rocker_port_is_bridged(rocker_port))
>>                 return -EINVAL;
>> --
>> 1.9.3
>>
