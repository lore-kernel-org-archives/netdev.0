From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [BUG] Crash with NULL pointer dereference in bond_handle_frame
 in -rt (possibly mainline)
Date: Sat, 30 Mar 2013 10:19:21 +0100
Message-ID: <20130330091921.GB1544@minipsycho.orion>
References: <1364490997.6345.237.camel@gandalf.local.home>
 <1364491792.15753.47.camel@edumazet-glaptop>
 <20130329094856.GB1677@minipsycho.orion>
 <1364582184.10629.34.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Guy Streeter <streeter@redhat.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>, stephen@networkplumber.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1364582184.10629.34.camel@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ri, Mar 29, 2013 at 07:36:24PM CET, rostedt@goodmis.org wrote:
>On Fri, 2013-03-29 at 10:48 +0100, Jiri Pirko wrote:
>
>> Because, if rcu_dereference(dev->rx_handler) is null,
>> rcu_dereference(dev->rx_handler_data) is never done. Therefore I bel=
ieve
>> we are hitting following scenario:
>>=20
>>=20
>>    CPU0				CPU1
>>    ----				----
>>   			    dev->rx_handler_data =3D NULL
>>  rcu_read_lock()
>>  			    dev->rx_handler =3D NULL
>>=20
>>=20
>
>That is not what is happening and that is not how RCU works. That is,
>rcu_read_lock() does not block nor does it really do much with orderin=
g
>at all.
>
>The problem is totally contained within the rcu_read_lock() as well:
>
>
>If you have:
>
>	rcu_read_lock();
>	rx_handler =3D dev->rx_handler;
>	rx_handler();
>	rcu_read_unlock();
>
>where rx_handler references rx->rx_handler_data you need much more tha=
n
>making sure that rx->handler is set to null before rx_handler_data.
>
>The way RCU works is it lets things exist in a "dual state". Kind of
>like a Sch=F6dinger's cat. The solution Eric posted is a classic RCU
>example of how this works.
>
>When you set dev->rx_handler to NULL, there's two states that currentl=
y
>exist in the system. Those that still see dev->rx_handler set to
>something and those that see it set to NULL. You could put in memory
>barriers to your hearts content, but you will still have a system that
>sees things in a dual state. If you set dev->rx_handler_data to NULL,
>you risk those that see rx_handler as a function can still reference t=
he
>rx_handler_data when it is NULL.
>
>Think of it this way:
>
>	dev->rx_handler() {
>
>Once the function has been called, even if you set rx_handler() to NUL=
L
>at this point, it makes no difference, even with memory barriers. This
>CPU is about to execute the previous value of rx_handler and there's
>nothing you can do to stop it. Setting rx_handler_data to NULL now can
>cause that CPU to reference the NULL pointer. There isn't a ordering
>problem where rx_handler_data got set to NULL first.
>
>But the beauty about RCU is the synchronize_*() functions, because tha=
t
>puts the system back into a single state. After the synchronization is
>complete, the entire system sees rx_handler() as NULL. There is no wor=
ry
>about setting rx_handler_data to NULL now because nothing will be
>referencing the previous value of rx_handler because that value no
>longer exists in the system.
>
>That means Eric's solution fits perfectly well here.
>
>	< system in single state : everyone sees rx_handler =3D function() >
>
>	rx_handler =3D NULL;
>
>	< system in dual state : new calls see rx_handler =3D NULL, but
>	  current calls see rx_handler =3D function >
>
>	synchronize_net();
>
>	< system is back to single state: everyone sees rx_handler =3D NULL >
>
>	rx_handler_data =3D NULL;
>
>no problem ;-)
>
>-- Steve


I think I understand now. I was under false impression that when rcu_re=
ad_lock()
is held, rcu_dereference(pointer) value is predetermined (for that
single run I mean).

Thank you very much for explanation!

Jiri

>
>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
