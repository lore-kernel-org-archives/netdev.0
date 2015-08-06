From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 2/7] net: switchdev: support static FDB addresses
Date: Thu, 6 Aug 2015 09:37:12 -0700
Message-ID: <CAE4R7bBRpEX+5J7Fbj=SuN8LcmcF8pH44y15emeB1pm_NgXGXw@mail.gmail.com>
References: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1438839848-505-3-git-send-email-vivien.didelot@savoirfairelinux.com>
 <CAE4R7bBjYZtE-hj8b-0bRcA2bB0Sh+YXhtcmk2FuJu_qLB3xew@mail.gmail.com> <20150806141934.GA20660@ketchup.touchtunes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150806141934.GA20660@ketchup.touchtunes.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 6, 2015 at 7:19 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> On 15-08-05 23:28:15, Scott Feldman wrote:
>> On Wed, Aug 5, 2015 at 10:44 PM, Vivien Didelot
>> <vivien.didelot@savoirfairelinux.com> wrote:
>> > This patch adds a is_static boolean to the switchdev_obj_fdb structure,
>> > in order to set the ndm_state to either NUD_NOARP or NUD_REACHABLE.
>> >
>> > Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> > ---
>> >  include/net/switchdev.h   | 1 +
>> >  net/switchdev/switchdev.c | 2 +-
>> >  2 files changed, 2 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>> > index e90e1a0..0e296b8 100644
>> > --- a/include/net/switchdev.h
>> > +++ b/include/net/switchdev.h
>> > @@ -72,6 +72,7 @@ struct switchdev_obj {
>> >                 struct switchdev_obj_fdb {              /* PORT_FDB */
>> >                         u8 addr[ETH_ALEN];
>> >                         u16 vid;
>> > +                       bool is_static;
>>
>> What do you think about changing this to u16 ndm_state?  That way, it
>> can be used on input (fdb add) and output (fdb dump), and the driver
>> can privately track the state, kind of like how the bridge keeps
>> is_static, is_local, etc.
>
> I'm OK with the change. Should we consider NUD_NONE (0) a valid value?
>
>> >                 } fdb;
>> >         } u;
>> >  };
>> > diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> > index 9db87a3..e9d1cac 100644
>> > --- a/net/switchdev/switchdev.c
>> > +++ b/net/switchdev/switchdev.c
>> > @@ -811,7 +811,7 @@ static int switchdev_port_fdb_dump_cb(struct net_device *dev,
>> >         ndm->ndm_flags   = NTF_SELF;
>> >         ndm->ndm_type    = 0;
>> >         ndm->ndm_ifindex = dev->ifindex;
>> > -       ndm->ndm_state   = NUD_REACHABLE;
>> > +       ndm->ndm_state   = obj->u.fdb.is_static ? NUD_NOARP : NUD_REACHABLE;
>
> In other word, do we prefer this:
>
>     ndm->ndm_state = obj->u.fdb.ndm_state == NUD_NONE ?
>                      NUD_REACHABLE : obj->u.fdb.ndm_state;
>
> Or this (meaning switchdev users cannot leave it blank and must at least
> set NUD_REACHABLE themselves):
>
>     ndm->ndm_state = obj->u.fdb.ndm_state;

My preference would be this option.
