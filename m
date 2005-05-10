From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 13:26:42 -0700 (PDT)
Message-ID: <20050510.132642.85686818.davem@davemloft.net>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
	<1115743966.8570.26.camel@rh4>
	<20050510.121214.39158393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mperaya@alcazaba.unex.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <20050510.121214.39158393.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 12:12:14 -0700 (PDT)

> Anyways, it is clear this code needs to change. :-)

I propose something like the patch below.  I unfortunately
discovered that the PCI-X boundary controls are limited, and
even worse PCI-E only allows controlling the write side and
not the read site at all. :-(

I think this should really be considered to be fixed
in future chip revisions, as performance will suffer
unnecessarily without proper boundary controls.  Even
just a single bit in the DMA RW control register which
says "do not cross PCI_CACHELINE_SIZE boundary" would
work just fine as that is essentially what the code below
is trying to convince the Tigon3 chip to do. :)

I am running this patch now on my sparc64 SunBlade1500
workstation's onboard 5703.

Comments?

[TG3]: Do not burst across cache line boundary on non-X86

PCI controllers on these systems will disconnect the tg3
when it crosses a cache line boundary anyways, wasting
precious PCI bandwidth.

Signed-off-by: David S. Miller <davem@davemloft.net>

--- drivers/net/tg3.c.~3~	2005-05-09 15:52:32.000000000 -0700
+++ drivers/net/tg3.c	2005-05-10 13:16:51.000000000 -0700
@@ -8865,33 +8865,93 @@
 		else
 			cacheline_size = (int) byte * 4;
 
-		switch (cacheline_size) {
-		case 16:
-		case 32:
-		case 64:
-		case 128:
-			if ((tp->tg3_flags & TG3_FLAG_PCIX_MODE) &&
-			    !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)) {
-				tp->dma_rwctrl |=
-					DMA_RWCTRL_WRITE_BNDRY_384_PCIX;
-				break;
-			} else if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
-				tp->dma_rwctrl &=
-					~(DMA_RWCTRL_PCI_WRITE_CMD);
+		/* PCI controllers on most RISC systems tend to disconnect
+		 * when a device tries to burst across a cache-line boundary.
+		 * Therefore, letting tg3 do so just wastes PCI bandwidth.
+		 *
+		 * Unfortunately, for PCI-E there are only limited
+		 * write-side controls for this, and thus for reads
+		 * we will still get the disconnects.
+		 */
+		if ((tp->tg3_flags & TG3_FLAG_PCIX_MODE) &&
+		    !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)) {
+			switch (cacheline_size) {
+			case 16:
+			case 32:
+			case 64:
+			case 128:
 				tp->dma_rwctrl |=
-					DMA_RWCTRL_WRITE_BNDRY_128_PCIE;
+					(DMA_RWCTRL_READ_BNDRY_128_PCIX |
+					 DMA_RWCTRL_WRITE_BNDRY_128_PCIX);
 				break;
-			}
-			/* fallthrough */
-		case 256:
-			if (!(tp->tg3_flags & TG3_FLAG_PCIX_MODE) &&
-			    !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS))
+
+			case 256:
+				tp->dma_rwctrl |=
+					(DMA_RWCTRL_READ_BNDRY_256_PCIX |
+					 DMA_RWCTRL_WRITE_BNDRY_256_PCIX);
+				break;
+
+			default:
+				tp->dma_rwctrl |=
+					(DMA_RWCTRL_READ_BNDRY_384_PCIX |
+					 DMA_RWCTRL_WRITE_BNDRY_384_PCIX);
+				break;
+			};
+		} else if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
+			switch (cacheline_size) {
+			case 16:
+			case 32:
+			case 64:
+				tp->dma_rwctrl |=
+					 DMA_RWCTRL_WRITE_BNDRY_64_PCIE;
+				break;
+
+			case 128:
+			default:
+				tp->dma_rwctrl |=
+					 DMA_RWCTRL_WRITE_BNDRY_128_PCIE;
+				break;
+			};
+		} else {
+			switch (cacheline_size) {
+			case 16:
+				tp->dma_rwctrl |=
+					(DMA_RWCTRL_READ_BNDRY_16 |
+					 DMA_RWCTRL_WRITE_BNDRY_16);
+				break;
+			case 32:
+				tp->dma_rwctrl |=
+					(DMA_RWCTRL_READ_BNDRY_32 |
+					 DMA_RWCTRL_WRITE_BNDRY_32);
+				break;
+			case 64:
+				tp->dma_rwctrl |=
+					(DMA_RWCTRL_READ_BNDRY_64 |
+					 DMA_RWCTRL_WRITE_BNDRY_64);
+				break;
+			case 128:
 				tp->dma_rwctrl |=
-					DMA_RWCTRL_WRITE_BNDRY_256;
-			else if (!(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS))
+					(DMA_RWCTRL_READ_BNDRY_128 |
+					 DMA_RWCTRL_WRITE_BNDRY_128);
+				break;
+			case 256:
+				tp->dma_rwctrl |=
+					(DMA_RWCTRL_READ_BNDRY_256 |
+					 DMA_RWCTRL_WRITE_BNDRY_256);
+				break;
+			case 512:
 				tp->dma_rwctrl |=
-					DMA_RWCTRL_WRITE_BNDRY_256_PCIX;
-		};
+					(DMA_RWCTRL_READ_BNDRY_512 |
+					 DMA_RWCTRL_WRITE_BNDRY_512);
+				break;
+			case 1024:
+			default:
+				tp->dma_rwctrl |=
+					(DMA_RWCTRL_READ_BNDRY_512 |
+					 DMA_RWCTRL_WRITE_BNDRY_512);
+				break;
+			};
+		}
 	}
 #endif
 
