From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: be2net failed to initialize regression
Date: Mon, 11 Mar 2013 11:07:49 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C0F25C2B3@CMEXMB1.ad.emulex.com>
References: <CF9D1877D81D214CB0CA0669EFAE020C0F259965@CMEXMB1.ad.emulex.com>
 <1916441684.11871533.1362967669686.JavaMail.root@redhat.com>
 <20130311025451.GA6646@shangw.(null)>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ivan Vecera <ivecera@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>,
	CAI Qian <caiqian@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130311025451.GA6646@shangw.(null)>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Gavin Shan [mailto:shangw@linux.vnet.ibm.com]
> >>
> >> Could you give me the FW version (ethtool -i) of the adapter (after
> >> be2net successfully probes in a 3.7 kernel.)
> >firmware-version: 2.104.281.0
> >>
> >> If the FW version is as old as 2.x, then the culprit commit that
> >> broke compatibility with old FW versions on some (BE2) chips I is:
> >> commit 1bc8e7e4f36c0c19dd7dea29e7c248b7c6ef3a15
> >> be2net: fix access to SEMAPHORE reg
> >>
> >> The fix for this is (still on David's net tree I guess):
> >> commit c5b3ad4c67989c778e4753be4f91dc7193a04d21
> >> be2net: use CSR-BAR SEMAPHORE reg for BE2/BE3
> 
> Sathya, the fix introduced to the following patch wouldn't be safe enough
> because it possiblly causes race condition: the f/w is resetted after detecting
> EEH errors and the f/w is far from ready yet. At that point, accessing CSR-BAR
> register would incur additional EEH error.
> Unfortunately, the corresponding PE (Partitioning Endpoint), to which the
> problematic adapter belongs, has been marked as frozen state. So the additional
> EEH error won't be recoverred at all. Eventually, it will lead to failure on
> resuming the adapter :-)

Gavin, the SEMAPHORE register is read/polled-on only in be_eeh_reset(), which
is called only after the adapter is reset. Why will this read incur an additional EEH error?

> 
> 
> be2net: use CSR-BAR SEMAPHORE reg for BE2/BE3
> 
> I'm thinking that we would still check POST status through PCI-CFG register and
> then ensure CSR-BAR on the problematic adapter is ready while resuming the
> adapter. That's just like what the patches I send do :-)

On BE2/BE3 chips, the PCI-CFG register cannot be relied on. As I mentioned in my
previous mails, it returns the wrong FW ready state.
