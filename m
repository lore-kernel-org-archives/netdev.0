From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH resend] drop_monitor: fix trace_napi_poll_hit()
Date: Mon, 31 Aug 2009 07:12:46 -0400
Message-ID: <20090831111245.GA2105@hmsreliant.think-freely.org>
References: <4A9B6963.5090207@cn.fujitsu.com> <4A9B6E57.7090703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751919AbZHaLM4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A9B6E57.7090703@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 31, 2009 at 08:31:51AM +0200, Eric Dumazet wrote:
> Xiao Guangrong a =E9crit :
> > The net_dev of backlog napi is NULL, like below:
> >=20
> > __get_cpu_var(softnet_data).backlog.dev =3D=3D NULL
> >=20
> > So, we should check it in napi tracepoint's probe function
> >=20
> > Acked-by: Neil Horman <nhorman@tuxdriver.com>
> > Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
> > ---
> >  net/core/drop_monitor.c |    3 ++-
> >  1 files changed, 2 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> > index 9d66fa9..d311202 100644
> > --- a/net/core/drop_monitor.c
> > +++ b/net/core/drop_monitor.c
> > @@ -182,7 +182,8 @@ static void trace_napi_poll_hit(struct napi_str=
uct *napi)
> >  	/*
> >  	 * Ratelimit our check time to dm_hw_check_delta jiffies
> >  	 */
> > -	if (!time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
> > +	if (!napi->dev ||
> > +	    !time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
> >  		return;
> > =20
> >  	rcu_read_lock();
>=20
>=20
> This reminds me dev->last_rx is not anymore updated, unless special c=
onditions
> are met.
>=20
I still see a large number of drivers that update dev->last_rx, althoug=
h its
not all as I look through the list, so something definately seems amiss=
=2E

If its not going to be consistently updated, why are still carrying tha=
t field
in dev?  Are we just waiting on someone to do the janitorial work to re=
move it?
If so, I can, and I'll fix up the drop monitor in the process, to use a=
 private
timestamp.

Neil

> Test done in trace_napi_poll_hit() is probably not good, even with a =
non null napi->dev
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
