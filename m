From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: Re: [PATCH] WLAN acx100: some optimization/cleanup
Date: Thu, 12 Jan 2006 15:43:01 +0100
Message-ID: <20060112144301.GB21084@rhlx01.fht-esslingen.de>
References: <20060112103706.GA12115@rhlx01.fht-esslingen.de> <200601121619.07669.vda@ilport.com.ua>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Andreas Mohr <andim2@users.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
Content-Disposition: inline
In-Reply-To: <200601121619.07669.vda@ilport.com.ua>
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Jan 12, 2006 at 04:19:07PM +0200, Denis Vlasenko wrote:
> On Thursday 12 January 2006 12:37, Andreas Mohr wrote:
> > [copying netdev for centralized development]
> >=20
> > Hi all,
> >=20
> > some updates to acx-20060111:
>=20
> I'm afraid I will take only part of it.

But still you're already taking part *in* it ;)
(thanks!)

> > - add some cache prefetching at critical places, but still unsure whe=
ther it
> >   helps (some rdtscl() testing hasn't shown much yet),
> >   thus make it configurable
>=20
> Prefetching should be used when one needs to traverse a *lot* of memory
> (example: fs code might use it in dentry/inode cache search algorithms)=
,
> but it is way below noise level in driver for a device with less than
> 30Mbit/s max throughput.
>=20
> This usage is possibly bogus:
>=20
>         /* now write the parameters of the command if needed */
> +       ACX_PREFETCHW(priv->cmd_area);
>         if (buffer && buflen) {
>                 /* if it's an INTERROGATE command, just pass the length
>                  * of parameters to read, as data */
>=20
> because priv->cmd_area points to PCI device's memory, not RAM.
> It is not cacheable. I think that writes won't be sped up at all
> by such prefetchw.

I think I've heard that somewhere... so you're most likely right.

> > - use "counter % 8" instead of "counter % 5" for easier ASM calculati=
on
>=20
> That is a wait loop, you should not cycle optimize those - you are
> waiting anyway, typically for a few ms at least!
Not execution time, code size! ;)

> If you really want to optimize it once and for all, do something like t=
his:
>=20
> priv member:
> =A0=A0=A0=A0=A0=A0=A0=A0wait_queue_head_t cmd_wait;
>=20
> in init code:
> init_waitqueue_head(&priv->cmd_wait);
>=20
> in issue_cmd():
> CLEAR_BIT(priv->irq_status, HOST_INT_CMD_COMPLETE);
> ...cmd setup...
> wait_event_interruptible_timeout(&priv->wait,
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0priv->irq_status & HOST=
_INT_CMD_COMPLETE,
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0cmd_ms_timeout*HZ/1000)=
;
> if (priv->irq_status & HOST_INT_CMD_COMPLETE)
> =A0=A0=A0=A0=A0=A0=A0=A0/* success */
>=20
> in IRQ handler:
> SET_BIT(priv->irq_status, HOST_INT_CMD_COMPLETE);
> wake_up(&priv->cmd_wait);
>=20
> This will save ~2.5 ms on average on each cmd.

Nice stuff, we should definitely go for it if possible (module init time
will benefit from that, it's currently 1.2 seconds on my P3/700, with
command requests being a sizeable part, despite the large firmware upload
which takes most of the remaining time!).

Are you going to add it already, or should this wait?

> > - add ACX_IE_HDR__TYPE_LEN define for IE struct header variables used
> >   everywhere
>=20
> Why is this useful?

In order to prevent typos/problems in this area:
I already had one case last week in the power save mode structs header
(u32 instead of u16) which caused this thing to not work properly
(already months ago when I first tried it!).
I discovered this mismatch by accident only!
If this define somehow happens to get altered in the future, then you *wi=
ll*
notice it immediately since *all* firmware structs will be affected then,=
 not
only such a very unimportant one as 802.11 powersave mode.

And of course also to keep header size down (...and compile time up).

> @@ -171,7 +179,7 @@
>  static inline int
>  mac_is_bcast(const u8 *mac)
>  {
> -       /* AND together 4 first bytes with sign-entended 2 last bytes
> +       /* AND together 4 first bytes with sign-extended 2 last bytes
>         ** Only bcast address gives 0xffffffff. +1 gives 0 */
>         return ( *(s32*)mac & ((s16*)mac)[2] ) + 1 =3D=3D 0;
>  }
>=20
> Took me 2 minutes to find the difference! :)

Sorry! ;)

Andreas Mohr


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
