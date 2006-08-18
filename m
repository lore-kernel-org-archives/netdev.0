From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/6]: powerpc/cell spidernet low watermark patch.
Date: Sat, 19 Aug 2006 01:09:13 +0200
Message-ID: <200608190109.15129.arnd@arndb.de>
References: <20060818220700.GG26889@austin.ibm.com>
	<20060818222146.GI26889@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: akpm@osdl.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, ens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: linuxppc-dev@ozlabs.org
In-Reply-To: <20060818222146.GI26889@austin.ibm.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Saturday 19 August 2006 00:21, Linas Vepstas wrote:
> +=A0=A0=A0=A0=A0=A0=A0/* Measure the length of the queue. */
> +=A0=A0=A0=A0=A0=A0=A0while (descr !=3D card->tx_chain.head) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0status =3D descr->dmac_cmd_=
status & SPIDER_NET_DESCR_NOT_IN_USE;
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if (status =3D=3D SPIDER_NE=
T_DESCR_NOT_IN_USE)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0bre=
ak;
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0descr =3D descr->next;
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0cnt++;
> +=A0=A0=A0=A0=A0=A0=A0}
> +=A0=A0=A0=A0=A0=A0=A0if (cnt =3D=3D 0)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return;
> +
> +=A0=A0=A0=A0=A0=A0=A0/* Set low-watermark 3/4th's of the way into the qu=
eue. */
> +=A0=A0=A0=A0=A0=A0=A0descr =3D card->tx_chain.tail;
> +=A0=A0=A0=A0=A0=A0=A0cnt =3D (cnt*3)/4;
> +=A0=A0=A0=A0=A0=A0=A0for (i=3D0;i<cnt; i++)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0descr =3D descr->next;

I wonder if calling this frequently results in a significant processing
overhead in the CPU. Does the spider_net_set_low_watermark function
show up in your profiles?

A more efficient implementation might be to mark one descriptor that
is at a fixed offset from the TX queue tail, so we only need to do

card->low_watermark->next->dmac_cmd_status |=3D SPIDER_NET_DESCR_TXDESFLG;
mb();
card->low_watermark->dmac_cmd_status &=3D ~SPIDER_NET_DESCR_TXDESFLG;
card->low_watermark =3D card->low_watermark->next;

when we queue another frame for TX.

	Arnd <><
