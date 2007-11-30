From: Peter Tiedemann <PTIEDEM@de.ibm.com>
Subject: Re: [patch 1/1] ctc: make use of alloc_netdev()
Date: Fri, 30 Nov 2007 02:33:57 +0100
Message-ID: <OFC3760A10.997938DA-ONC12573A3.00077088-C12573A3.00089A9D@de.ibm.com>
References: <20071129091235.7884f0ad@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org, Ursula Braun1 <braunu@de.ibm.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:51626 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763732AbXK3BeC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 20:34:02 -0500
In-Reply-To: <20071129091235.7884f0ad@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To maintain the area used for sysfs attribute data which may be stored
already previously.

Mit freundlichen Gr=FC=DFen / Best regards / Saluti,
          Peter Tiedemann
---------------------------------
phone: +49-7031-16-4172   fax: ++3159    e-mail: PTiedem@de.ibm.com
IBM Deutschland Entwicklung GmbH
Linux for eServer Development, Dept. 3303
Schoenaicher Str. 220
71032 Boeblingen, Germany

IBM Deutschland Entwicklung GmbH, Vorsitzender des Aufsichtsrats: Marti=
n
Jetter, Gesch=E4ftsf=FChrung: Herbert Kircher
Sitz der Gesellschaft: B=F6blingen, Registergericht: Amtsgericht Stuttg=
art,
HRB 243294


                                                                       =
   =20
             Stephen Hemminger                                         =
   =20
             <shemminger@linux                                         =
   =20
             -foundation.org>                                          =
 To=20
                                       Ursula Braun1/Germany/IBM@IBMDE =
   =20
             29.11.2007 18:12                                          =
 cc=20
                                       jgarzik@pobox.com,              =
   =20
                                       netdev@vger.kernel.org,         =
   =20
                                       linux-s390@vger.kernel.org, Pete=
r  =20
                                       Tiedemann/Germany/IBM@IBMDE     =
   =20
                                                                   Subj=
ect=20
                                       Re: [patch 1/1] ctc: make use of=
   =20
                                       alloc_netdev()                  =
   =20
                                                                       =
   =20
                                                                       =
   =20
                                                                       =
   =20
                                                                       =
   =20
                                                                       =
   =20
                                                                       =
   =20




On Thu, 29 Nov 2007 17:36:27 +0100
Ursula Braun <braunu@de.ibm.com> wrote:

> From: Peter Tiedemann <ptiedem@de.ibm.com>
>
> Currently ctc-device initialization is broken (kernel bug in
> ctc_new_device).
> The new network namespace code reveals a deficiency of the
> ctc driver. It should make use of alloc_netdev() as described
> in Documentation/networking/netdevices.txt.
>
> Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
> Signed-off-by: Ursula Braun <braunu@de.ibm.com>
> ---
>  drivers/s390/net/ctcmain.c |   45
++++++++++++++++-----------------------------
>  1 file changed, 16 insertions(+), 29 deletions(-)
>
> Index: linux-2.6-uschi/drivers/s390/net/ctcmain.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6-uschi.orig/drivers/s390/net/ctcmain.c
> +++ linux-2.6-uschi/drivers/s390/net/ctcmain.c
> @@ -2782,35 +2782,14 @@ ctc_probe_device(struct ccwgroup_device
>  }
>
>  /**
> - * Initialize everything of the net device except the name and the
> - * channel structs.
> + * Device setup function called by alloc_netdev().
> + *
> + * @param dev  Device to be setup.
>   */
> -static struct net_device *
> -ctc_init_netdevice(struct net_device * dev, int alloc_device,
> -                         struct ctc_priv *privptr)
> +void ctc_init_netdevice(struct net_device * dev)
>  {
> -          if (!privptr)
> -                      return NULL;
> -
>            DBF_TEXT(setup, 3, __FUNCTION__);
>
> -          if (alloc_device) {
> -                      dev =3D kzalloc(sizeof(struct net_device),
GFP_KERNEL);
> -                      if (!dev)
> -                                  return NULL;
> -          }
> -
> -          dev->priv =3D privptr;
> -          privptr->fsm =3D init_fsm("ctcdev", dev_state_names,
> -                                              dev_event_names,
CTC_NR_DEV_STATES, CTC_NR_DEV_EVENTS,
> -                                              dev_fsm, DEV_FSM_LEN,
GFP_KERNEL);
> -          if (privptr->fsm =3D=3D NULL) {
> -                      if (alloc_device)
> -                                  kfree(dev);
> -                      return NULL;
> -          }
> -          fsm_newstate(privptr->fsm, DEV_STATE_STOPPED);
> -          fsm_settimer(privptr->fsm, &privptr->restart_timer);
>            if (dev->mtu =3D=3D 0)
>                        dev->mtu =3D CTC_BUFSIZE_DEFAULT - LL_HEADER_L=
ENGTH
- 2;
>            dev->hard_start_xmit =3D ctc_tx;
> @@ -2823,7 +2802,7 @@ ctc_init_netdevice(struct net_device * d
>            dev->type =3D ARPHRD_SLIP;
>            dev->tx_queue_len =3D 100;
>            dev->flags =3D IFF_POINTOPOINT | IFF_NOARP;
> -          return dev;
> +          SET_MODULE_OWNER(dev);
>  }
>
>
> @@ -2879,14 +2858,22 @@ ctc_new_device(struct ccwgroup_device *c
>                                    "ccw_device_set_online (cdev[1])
failed with ret =3D %d\n", ret);
>            }
>
> -          dev =3D ctc_init_netdevice(NULL, 1, privptr);
> -
> +          dev =3D alloc_netdev(0, "ctc%d", ctc_init_netdevice);
>            if (!dev) {
>                        ctc_pr_warn("ctc_init_netdevice failed\n");
>                        goto out;
>            }
> +          dev->priv =3D privptr;
>
Why not use standard private data area, rather than allocating
it separately?

--
Stephen Hemminger <shemminger@linux-foundation.org>


