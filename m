From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] mlx4_en: fix transmit of packages when blue frame
	isenabled
Date: Thu, 6 Oct 2011 15:10:28 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AE76@saturn3.aculab.com>
References: <20111006135759.GH2681@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli@mellanox.co.il>, Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: "Eli Cohen" <eli@dev.mellanox.co.il>,
	"Thadeu Lima de Souza Cascardo" <cascardo@linux.vnet.ibm.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-class: urn:content-classes:message
In-Reply-To: <20111006135759.GH2681@mtldesk30>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

 
>  static void mlx4_bf_copy(unsigned long *dst, unsigned long *src,
unsigned bytecnt) {
> +	int i;
> +	__le32 *psrc = (__le32 *)src;
> +
> +	/*
> +	 * the buffer is already in big endian. For little endian
machines that's
> +	 * fine. For big endain machines we must swap since the chipset
swaps again
> +	 */
> +	for (i = 0; i < bytecnt / 4; ++i)
> +		psrc[i] = le32_to_cpu(psrc[i]);
> +
>  	__iowrite64_copy(dst, src, bytecnt / 8);
>  }

That code looks horrid...
1) I'm not sure the caller expects the buffer to be corrupted.
2) It contains a lot of memory cycles.
3) It looked from the calls that this code is copying descriptors,
   so the transfer length is probably 1 or 2 words - so the loop
   is inefficient.
4) ppc doesn't have a fast byteswap instruction (very new gcc might
   use the byteswapping memery access for the le32_to_cpu() though),
   so it would be better getting the byteswap done inside
   __iowrite64_copy() - since that is probably requesting a byteswap
   anyway.
OTOH I'm not at all clear about the 64bit xfers....
