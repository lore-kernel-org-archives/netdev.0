From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: REGRESSION f54b311142a92ea2e42598e347b84e1655caf8e3 tcp auto
 corking slows down iSCSI file system creation by factor of 70 [WAS: 4 TB
 VMFS creation takes 15 minutes vs 26 seconds]
Date: Sat, 08 Feb 2014 06:13:36 -0800
Message-ID: <1391868816.10160.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140206153640.GB4103@glanzmann.de>
	 <1391727771.14985.41.camel@haakon3.risingtidesystems.com>
	 <20140207051500.GB10916@glanzmann.de> <20140207075536.GB17815@glanzmann.de>
	 <1391801597.1155.28.camel@haakon3.risingtidesystems.com>
	 <20140207205142.GA8609@glanzmann.de> <20140208093808.GD16336@glanzmann.de>
	 <1391865273.10160.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391866389.10160.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391867404.10160.88.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391867404.10160.88.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-02-08 at 05:50 -0800, Eric Dumazet wrote:
> On Sat, 2014-02-08 at 05:33 -0800, Eric Dumazet wrote:
> > On Sat, 2014-02-08 at 05:14 -0800, Eric Dumazet wrote:
> > > Here is the combined patch, could you test it ?
> > 
> > Also make sure you have commit a181ceb501b31b4bf8812a5c84c716cc31d82c2d
> > ("tcp: autocork should not hold first packet in write queue")
> > in your tree.
> > 
> > 
> 
> BTW this problem demonstrates there is room for improvement in iCSCI,
> using MSG_MORE to avoid sending two small segments in separate frames.
> 
> [1] 00:32:35.726568 IP 10.101.99.5.3260 > 10.101.0.13.27778: Flags [P.], seq 145:193, ack 144, win 235, options [nop,nop,TS val 4294960733 ecr 385385], length 48
> [2] 00:32:35.838074 IP 10.101.0.13.27778 > 10.101.99.5.3260: Flags [.], ack 193, win 514, options [nop,nop,TS val 385396 ecr 4294960733], length 0
> [3] 00:32:35.838099 IP 10.101.99.5.3260 > 10.101.0.13.27778: Flags [P.], seq 193:705, ack 144, win 235, options [nop,nop,TS val 4294960761 ecr 385396], length 512
> 
> [1] & [3] could be coalesced, and [2] would be avoided.
> 

With the fix, new pcap is more explicit about this suboptimal behavior :

05:34:16.280900 IP 10.101.0.13.41531 > 10.101.99.5.3260: Flags [.], ack 54353, win 514, options [nop,nop,TS val 1732452 ecr 4294935370], length 0
05:34:16.280949 IP 10.101.0.13.41531 > 10.101.99.5.3260: Flags [P.], seq 5328:5376, ack 54353, win 514, options [nop,nop,TS val 1732452 ecr 4294935370], length 48

05:34:16.280982 IP 10.101.99.5.3260 > 10.101.0.13.41531: Flags [P.], seq 54353:54401, ack 5376, win 235, options [nop,nop,TS val 4294935370 ecr 1732452], length 48
05:34:16.281000 IP 10.101.99.5.3260 > 10.101.0.13.41531: Flags [P.], seq 54401:54913, ack 5376, win 235, options [nop,nop,TS val 4294935370 ecr 1732452], length 512

05:34:16.281107 IP 10.101.0.13.41531 > 10.101.99.5.3260: Flags [.], ack 54913, win 514, options [nop,nop,TS val 1732452 ecr 4294935370], length 0
05:34:16.281157 IP 10.101.0.13.41531 > 10.101.99.5.3260: Flags [P.], seq 5376:5424, ack 54913, win 514, options [nop,nop,TS val 1732452 ecr 4294935370], length 48

05:34:16.281190 IP 10.101.99.5.3260 > 10.101.0.13.41531: Flags [P.], seq 54913:54961, ack 5424, win 235, options [nop,nop,TS val 4294935370 ecr 1732452], length 48
05:34:16.281208 IP 10.101.99.5.3260 > 10.101.0.13.41531: Flags [P.], seq 54961:55473, ack 5424, win 235, options [nop,nop,TS val 4294935370 ecr 1732452], length 512

05:34:16.281337 IP 10.101.0.13.41531 > 10.101.99.5.3260: Flags [.], ack 55473, win 514, options [nop,nop,TS val 1732452 ecr 4294935370], length 0
05:34:16.281390 IP 10.101.0.13.41531 > 10.101.99.5.3260: Flags [P.], seq 5424:5472, ack 55473, win 514, options [nop,nop,TS val 1732452 ecr 4294935370], length 48

05:34:16.281423 IP 10.101.99.5.3260 > 10.101.0.13.41531: Flags [P.], seq 55473:55521, ack 5472, win 235, options [nop,nop,TS val 4294935370 ecr 1732452], length 48
05:34:16.281440 IP 10.101.99.5.3260 > 10.101.0.13.41531: Flags [P.], seq 55521:56033, ack 5472, win 235, options [nop,nop,TS val 4294935370 ecr 1732452], length 512
