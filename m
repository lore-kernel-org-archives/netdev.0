From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] WLAN acx100: some optimization/cleanup
Date: Thu, 12 Jan 2006 16:19:07 +0200
Message-ID: <200601121619.07669.vda@ilport.com.ua>
References: <20060112103706.GA12115@rhlx01.fht-esslingen.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: quoted-printable
Cc: Andreas Mohr <andim2@users.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <20060112103706.GA12115@rhlx01.fht-esslingen.de>
Content-Disposition: inline
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

On Thursday 12 January 2006 12:37, Andreas Mohr wrote:
> [copying netdev for centralized development]
>=20
> Hi all,
>=20
> some updates to acx-20060111:

I'm afraid I will take only part of it.
=20
> - add some cache prefetching at critical places, but still unsure whether=
 it
>   helps (some rdtscl() testing hasn't shown much yet),
>   thus make it configurable

Prefetching should be used when one needs to traverse a *lot* of memory
(example: fs code might use it in dentry/inode cache search algorithms),
but it is way below noise level in driver for a device with less than
30Mbit/s max throughput.

This usage is possibly bogus:

        /* now write the parameters of the command if needed */
+       ACX_PREFETCHW(priv->cmd_area);
        if (buffer && buflen) {
                /* if it's an INTERROGATE command, just pass the length
                 * of parameters to read, as data */

because priv->cmd_area points to PCI device's memory, not RAM.
It is not cacheable. I think that writes won't be sped up at all
by such prefetchw.

> - add recommended cpu_relax() to busy-wait loops

I do not think these are noticeable, but why not? Taken.

> - use "counter % 8" instead of "counter % 5" for easier ASM calculation

That is a wait loop, you should not cycle optimize those - you are
waiting anyway, typically for a few ms at least!
If you really want to optimize it once and for all, do something like this:

priv member:
=9A=9A=9A=9A=9A=9A=9A=9Await_queue_head_t cmd_wait;

in init code:
init_waitqueue_head(&priv->cmd_wait);

in issue_cmd():
CLEAR_BIT(priv->irq_status, HOST_INT_CMD_COMPLETE);
=2E..cmd setup...
wait_event_interruptible_timeout(&priv->wait,
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Apriv->irq_status & HOST_INT=
_CMD_COMPLETE,
=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Acmd_ms_timeout*HZ/1000);
if (priv->irq_status & HOST_INT_CMD_COMPLETE)
=9A=9A=9A=9A=9A=9A=9A=9A/* success */

in IRQ handler:
SET_BIT(priv->irq_status, HOST_INT_CMD_COMPLETE);
wake_up(&priv->cmd_wait);

This will save ~2.5 ms on average on each cmd.

> - add ACX_IE_HDR__TYPE_LEN define for IE struct header variables used
>   everywhere

Why is this useful?

> - reorder struct wlandevice_t for better(??) cache use

Ok, but again I don't think it's noticeable.

> - kill superfluous result variable in conv.c

ok

> - misc. small cleanup

ok

> This patch is rediffed from my modified acx-20060109 tar, NOT compile-tes=
ted!

@@ -171,7 +179,7 @@
 static inline int
 mac_is_bcast(const u8 *mac)
 {
=2D       /* AND together 4 first bytes with sign-entended 2 last bytes
+       /* AND together 4 first bytes with sign-extended 2 last bytes
        ** Only bcast address gives 0xffffffff. +1 gives 0 */
        return ( *(s32*)mac & ((s16*)mac)[2] ) + 1 =3D=3D 0;
 }

Took me 2 minutes to find the difference! :)

Thanks!
=2D-
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
