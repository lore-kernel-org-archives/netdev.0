From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFT] BIC TCP delayed ack compensation
Date: Wed, 23 Feb 2005 17:04:08 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0502231436170.28189@dexter.psc.edu>
References: <052Q0TU11@server5.heliogroup.fr> <200502231835.j1NIZX2T020606@uni07mr.unity.ncsu.edu>
 <20050223112611.60561121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hubert.tonneau@fullpliant.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050223112611.60561121.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Feb 2005, David S. Miller wrote:

> I don't think BIC has much to do with this problem.  MacOS-X does delayed
> ACKs until a PSH is seen and this kills performance if we don't PSH often
> enough.


I looked at the trace last night and I wonder if PSH is a red herring.
For example:

16:42:21.837931 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: . ack 37545601 win 57184 <nop,nop,timestamp 1709240872 641486>
16:42:21.837937 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37545601:37547049(1448) ack 122802 win 1460 <nop,nop,timestamp 641685 1709240872> NBT Packet
16:42:21.837940 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37547049:37548497(1448) ack 122802 win 1460 <nop,nop,timestamp 641685 1709240872> NBT Packet
16:42:21.837941 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37548497:37549945(1448) ack 122802 win 1460 <nop,nop,timestamp 641685 1709240872> NBT Packet
16:42:21.837943 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37549945:37551393(1448) ack 122802 win 1460 <nop,nop,timestamp 641685 1709240872> NBT Packet
16:42:21.837945 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37551393:37552841(1448) ack 122802 win 1460 <nop,nop,timestamp 641685 1709240872> NBT Packet
16:42:21.837947 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37552841:37554289(1448) ack 122802 win 1460 <nop,nop,timestamp 641685 1709240872> NBT Packet
16:42:21.837949 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37554289:37555737(1448) ack 122802 win 1460 <nop,nop,timestamp 641685 1709240872> NBT Packet
16:42:21.838979 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: . ack 37552841 win 65535 <nop,nop,timestamp 1709240872 641685>
16:42:21.838985 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37555737:37557185(1448) ack 122802 win 1460 <nop,nop,timestamp 641686 1709240872> NBT Packet
16:42:21.838987 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37557185:37558633(1448) ack 122802 win 1460 <nop,nop,timestamp 641686 1709240872> NBT Packet
16:42:21.838989 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37558633:37560081(1448) ack 122802 win 1460 <nop,nop,timestamp 641686 1709240872> NBT Packet
16:42:21.838991 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37560081:37561529(1448) ack 122802 win 1460 <nop,nop,timestamp 641686 1709240872> NBT Packet
16:42:21.838992 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37561529:37562977(1448) ack 122802 win 1460 <nop,nop,timestamp 641686 1709240872> NBT Packet
16:42:21.838994 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: . 37562977:37564425(1448) ack 122802 win 1460 <nop,nop,timestamp 641686 1709240872> NBT Packet
16:42:21.839172 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: P 122802:122853(51) ack 37554289 win 65128 <nop,nop,timestamp 1709240872 641685> NBT Packet
16:42:21.839178 IP 10.107.96.7.32801 > 10.107.96.230.netbios-ssn: P 37564425:37565873(1448) ack 122853 win 1460 <nop,nop,timestamp 641686 1709240872> NBT Packet
16:42:22.037976 IP 10.107.96.230.netbios-ssn > 10.107.96.7.32801: . ack 37565873 win 53548 <nop,nop,timestamp 1709240872 641685>

Maybe this has something to do with the bi-directional nature of the flow?
Mac OS delaying ACK to try to piggyback on data or something like that.
One signature I noticed is that it seems the last packet sent by the Mac
before the long delack timeout is always a small data packet.  (I didn't
rigorously verify this but it seems true.)

  -John
