From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 15:06:54 -0600
Message-ID: <200501071506.57811.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <200501071414.05126.jeremy.guthrie@berbee.com> <16862.62424.180929.680029@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1122471.8x5onAmVJB";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16862.62424.180929.680029@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1122471.8x5onAmVJB
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 07 January 2005 02:40 pm, Robert Olsson wrote:
> Jeremy M. Guthrie writes:
>  > During a 60 second window the machine received 5,110,164 packets and
>  > dropped 20461 or roughly 0.4% packet loss.
>
>  Around 85 kpps. If you run rtstat we could a feeling how may slow-pathx
>  that are taken.=20
I can't run rstat.  The rt_cache_stat file doesn't exist in /proc/net=20
or /proc/net/stat in either V2.4 or V2.6.

>  Or save the /proc/net/stat/rt_cache before you 60 sec=20
>  run.
lnstat isn't giving me anything other than zeros. =20

entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_sr=
c =20
out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss=20
gc_dst_overflow in_hlist_search out_hlist_search
0000f91e  15b1ddab 0b69a32c 00000000 00000000 00001b0a 00001fbd 00000000 =20
00066f65 0000b943 00000000 087b80a1 0878e81a 00000256 00000000 ca08c77d=20
0020e549
0000f91e  00005c59 0000b3ef 00000000 00000000 00000cf7 00000000 00000000 =20
0000000f 0000004c 00000002 00000fb9 00000fb5 00000000 00000000 0004e8d9=20
000000b2

60 seconds......

entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_sr=
c =20
out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss=20
gc_dst_overflow in_hlist_search out_hlist_search
0000fb3e  15ff4696 0b6bbb65 00000000 00000000 00001b10 00001fc1 00000000 =20
00067111 0000b974 00000000 087d9903 087b0003 00000256 00000000 cb58b399=20
0020ee79
0000fb3e  00005c5b 0000b40d 00000000 00000000 00000cf9 00000000 00000000 =20
0000000f 0000004c 00000002 00000fbb 00000fb7 00000000 00000000 0004e9ba=20
000000b2



>  mpstat I don't trust in this context.
>
>  > It has been at 150dc67c for a while now.  So while I am dropping at the
>  > card, I am not dropping in the stack.
>
>  You use NAPI driver then...
>  Check if the patch below is in your e1000 driver.
>            --ro
The drivers should be built as NAPI.

Here is the snippet:
static int
e1000_clean(struct net_device *netdev, int *budget)
{
        struct e1000_adapter *adapter =3D netdev->priv;
        int work_to_do =3D min(*budget, netdev->quota);
        int tx_cleaned;
        int work_done =3D 0;

        if (!netif_carrier_ok(netdev))
                goto quit_polling;

        tx_cleaned =3D e1000_clean_tx_irq(adapter);
        e1000_clean_rx_irq(adapter, &work_done, work_to_do);

        *budget -=3D work_done;
        netdev->quota -=3D work_done;

        /* if no Rx and Tx cleanup work was done, exit the polling mode */
        if(!tx_cleaned || (work_done < work_to_do) ||
                                !netif_running(netdev)) {
quit_polling:   netif_rx_complete(netdev);
                e1000_irq_enable(adapter);
                return 0;
        }

        return (work_done >=3D work_to_do);
}



>
>  --- drivers/net/e1000/e1000_main.c.orig 2004-02-16 14:46:16.000000000
> +0100 +++ drivers/net/e1000/e1000_main.c 2004-02-16 15:45:05.000000000
> +0100 @@ -2161,19 +2161,21 @@
>   struct e1000_adapter *adapter =3D netdev->priv;
>   int work_to_do =3D min(*budget, netdev->quota);
>   int work_done =3D 0;
> -
> - e1000_clean_tx_irq(adapter);
> + static boolean_t tx_cleaned;
> +
> + tx_cleaned =3D e1000_clean_tx_irq(adapter);
>   e1000_clean_rx_irq(adapter, &work_done, work_to_do);
>
>   *budget -=3D work_done;
>   netdev->quota -=3D work_done;
>
> - if(work_done < work_to_do || !netif_running(netdev)) {
> + if( (!tx_cleaned && (work_done =3D=3D 0)) || !netif_running(netdev)) {
>    netif_rx_complete(netdev);
>    e1000_irq_enable(adapter);
> +  return 0;
>   }
>
> - return (work_done >=3D work_to_do);
> +	return 1;
>  }
>  #endif

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1122471.8x5onAmVJB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB3vnxqtjaBHGZBeURAqa6AJ95YCgRBAIzM0qXYxDLWsgpjuQW6QCgmyUT
PAcawdHWqMOb939ioWONMRA=
=5vpR
-----END PGP SIGNATURE-----

--nextPart1122471.8x5onAmVJB--
