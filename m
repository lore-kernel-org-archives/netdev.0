From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCHv2 net-next 09/11] net: mvpp2: simplify MVPP2_PRS_RI_*
 definitions
Date: Fri, 6 Jan 2017 13:07:27 +0000
Message-ID: <20170106130727.GB14217@n2100.armlinux.org.uk>
References: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943567-12483-10-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
 Hanna Hawa <hannah@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1482943567-12483-10-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 28, 2016 at 05:46:05PM +0100, Thomas Petazzoni wrote:
> Some of the MVPP2_PRS_RI_* definitions use the ~(value) syntax, which
> doesn't compile nicely on 64-bit. Moreover, those definitions are in
> fact unneeded, since they are always used in combination with a bit
> mask that ensures only the appropriate bits are modified.
> 
> Therefore, such definitions should just be set to 0x0. For example:
> 
>  #define MVPP2_PRS_RI_L2_CAST_MASK              0x600
>  #define MVPP2_PRS_RI_L2_UCAST                  ~(BIT(9) | BIT(10))
>  #define MVPP2_PRS_RI_L2_MCAST                  BIT(9)
>  #define MVPP2_PRS_RI_L2_BCAST                  BIT(10)
> 
> becomes
> 
>  #define MVPP2_PRS_RI_L2_CAST_MASK              0x600
>  #define MVPP2_PRS_RI_L2_UCAST                  0x0
>  #define MVPP2_PRS_RI_L2_MCAST                  BIT(9)
>  #define MVPP2_PRS_RI_L2_BCAST                  BIT(10)

So this is a two-bit field in a register with three defined states - I'm
not sure that using BIT() here is really a good idea.  BIT() is fine for
single-bit controls, but I think it adds an additional level of confusion
for multi-bit controls.

Also, the combination of the mask being defined as hex and the controls
using BIT() is particularly not nice.  I think either use one style or
the other, don't mix them.  So either:

  #define MVPP2_PRS_RI_L2_CAST_MASK              0x600
  #define MVPP2_PRS_RI_L2_UCAST                  0x000
  #define MVPP2_PRS_RI_L2_MCAST                  0x200
  #define MVPP2_PRS_RI_L2_BCAST                  0x400

or:

  #define MVPP2_PRS_RI_L2_CAST_MASK              (BIT(10) | BIT(9))
  #define MVPP2_PRS_RI_L2_UCAST                  0
  #define MVPP2_PRS_RI_L2_MCAST                  BIT(9)
  #define MVPP2_PRS_RI_L2_BCAST                  BIT(10)

It then becomes obvious that the mask and the settings are changing the
same bits.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
