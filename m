From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Sun, 09 Oct 2011 09:19:45 +0200
Message-ID: <1318144785.29415.367.camel@pasglop>
References: <1317388995-411-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <953B660C027164448AE903364AC447D2235D9A8C@MTLDAG02.mtl.com>
 <20111003143721.GA3596@oc1711230544.ibm.com>
 <953B660C027164448AE903364AC447D2235DAA9D@MTLDAG02.mtl.com>
 <20111003205358.GB3596@oc1711230544.ibm.com>
 <1317708132.29415.213.camel@pasglop>
 <20111004202620.GA3455@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Eli Cohen <eli@mellanox.co.il>,
 "eli@dev.mellanox.co.il" <eli@dev.mellanox.co.il>,
 linuxppc-dev@lists.ozlabs.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20111004202620.GA3455@oc1711230544.ibm.com>
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

On Tue, 2011-10-04 at 17:26 -0300, Thadeu Lima de Souza Cascardo wrote:

>         if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
> !vlan_tag) {
>                 *(u32 *) (&tx_desc->ctrl.vlan_tag) |=
> ring->doorbell_qpn;

Could this have endianness problems ?

>                 op_own |= htonl((bf_index & 0xffff) << 8);

Probably better to use cpu_to_be/lexx() here. Also make sure your
descriptors are defined with the appropriate __beXX or __leXX types
so sparse can tell you when you get this wrong

>                 /* Ensure new descirptor hits memory
>                 * before setting ownership of this descriptor to HW */
>                 wmb();
>                 tx_desc->ctrl.owner_opcode = op_own;

>                 wmb();
> 
>                 mlx4_bf_copy(ring->bf.reg + ring->bf.offset, (unsigned
> long *) &tx_desc->ctrl,
>                      desc_size);

What does the above do ?

>                 wmb();
> 
>                 ring->bf.offset ^= ring->bf.buf_size;

Is this HW visible ? It's a bit odd, are you doing double bufferring and
trying to flip a bit ? If it's HW visible, is endian correct ?
 
        } else {
>                 /* Ensure new descirptor hits memory
>                 * before setting ownership of this descriptor to HW */
>                 wmb();
>                 tx_desc->ctrl.owner_opcode = op_own;
> -               wmb();
> -               writel(ring->doorbell_qpn, ring->bf.uar->map +
> MLX4_SEND_DOORBELL);
>         }
> 
> +       wmb();
> +       writel(ring->doorbell_qpn, ring->bf.uar->map +
> MLX4_SEND_DOORBELL);
> +
> ---

Cheers,
Ben.
