From: Madoka Komatsubara <m-komatsubara@ab.jp.nec.com>
Subject: Re: Unable to receive multicast packet on VF
Date: Fri, 11 Apr 2014 09:58:37 +0000
Message-ID: <9DE5760509B7974286F38D93BF31DD62C80152@BPXM13GP.gisp.nec.co.jp>
References: <9DE5760509B7974286F38D93BF31DD62C7D0B8@BPXM13GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF2228664685D9725C@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Hiroshi Baba <h-baba@ax.jp.nec.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Komatsubara Madoka(小松原 円)
> Sent: Wednesday, April 02, 2014 6:05 PM
> To: 'Skidmore, Donald C'; linux-kernel@vger.kernel.org;
> e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
> Cc: Shimamoto Hiroshi(島本 裕志); Baba Hiroshi(馬場 裕司)
> Subject: RE: Unable to receive multicast packet on VF
> 
> 
> > -----Original Message-----
> > From: Skidmore, Donald C [mailto:donald.c.skidmore@intel.com]
> > Sent: Saturday, March 29, 2014 5:54 AM
> > To: Komatsubara Madoka(小松原 円); linux-kernel@vger.kernel.org;
> > e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
> > Cc: Shimamoto Hiroshi(島本 裕志); Baba Hiroshi(馬場 裕司)
> > Subject: RE: Unable to receive multicast packet on VF
> >
> >
> >
> > > -----Original Message-----
> > > From: Madoka Komatsubara [mailto:m-komatsubara@ab.jp.nec.com]
> > > Sent: Friday, March 28, 2014 4:49 AM
> > > To: linux-kernel@vger.kernel.org; e1000-devel@lists.sourceforge.net;
> > > netdev@vger.kernel.org
> > > Cc: Hiroshi Shimamoto; Hiroshi Baba
> > > Subject: [E1000-devel] Unable to receive multicast packet on VF
> > >
> > > Hi all,
> > >
> > >
> > > We would like to use multicast packet on the guest with Intel
> > > 82599EB
> > > SR- IOV.
> > > However, the document says that adding the multicast MAC address to
> > > the VF is allowed during PF initialization only. (Please refer to
> > > the URL below.) It means that we couldn't handle dynamically
> > > allocated multicast
> > address.
> > >
> > > On the other hand,
> > > >From the data sheet, 82599EB has Multicast Promiscuous mode.
> > > We could enable it on PF and all multicast packets are delivered to
> > > every
> > VF.
> > > That doesn't seem good, because each guest has to handle unnecessary
> > > packet.
> > >
> > > Isn't it good to have a feature to add specific multicast address to VF?
> > > Does anyone know that issue or the solution?
> > >
> > >
> > >
> > > <http://www.intel.com/content/dam/www/public/us/en/documents/datas
> > > heets/82599-10-gbe-controller-datasheet.pdf>
> > >  page585
> > >  section 8.2.3.7.7
> > >  "This table should be initialized by software before transmit and
> > > receive are enabled."
> > >
> > > Regards,
> > > Madoka Komatsubara
> > >
> >
> > Hi Madoka,
> >
> > You can see where we are changing the multicast address list in the VF
> > driver in ixgbevf_set_rx_mode().  This not only called via ndo_set_rx_mode
> but in
> > our up and open calls.   So while it is true this needs to be initialized
> before
> > transmit and receive are enabled, the value can be changed without
> > requiring the module to be reloaded.
> >
> > Hope that helps,
> > -Don
> 
> 
> Hi Donald,
> 
> Thank you for your information.
> it is currently under consideration.
> I will contact you again later.
> 
> 
> Regards,
> Madoka Komatsubara

Hi Donald,

I'm sorry for the delay in my response.


We would like to clarify the limitation described in the datasheet.

We confirmed if the multicast address list is updated in the VF driver with
 the instruction below.
The scenario is that the guest on host1 has an address on network1 and
 communicate with host2, on the same time, the guest newly gets an address
 on network2 and begin to communicate with host3.
The result was that we could add new IPv6 address on the VF and receive new
 multicast address packet.

We can't understand exactly what the description section 8.2.3.7.7(page585)
 in the 82599 datasheet
http://www.intel.com/content/dam/www/public/us/en/documents/datasheets/82599-10-gbe-controller-datasheet.pdf
"This table should be initialized by software before transmit and receive
 are enabled."


Could you please tell us what "before transmit and receive are enabled" means?
We would like to add new communication on keeping previous packet communication.
And the result looks fine.



Here is our test scenario
Step1:
  o Guest on the host1
     Guest# ifconfig eth1 add 3ffe:5::fe/64
      This is registered to a multicast filter of guest.
  o Host2
     Host2# ifconfig eth1 add 3ffe:5::fd/64
     Host2# ping6 -c1 3ffe:5::fe
      Guest receives a packet for the multicast address.

Step2:
  Next, we confirmed if the multicast address list is updated while pinging.
  We keep on pinging to the guest from the host2.
  o Host2
     Host2# ping6 3ffe:5::fe
  After that, we add new IPv6 address on the VF.
  o Guest on the host1
     Guest# ifconfig eth1 add 3ffd:5::aa/64
      This is added to the multicast filter of guest.
      This is inconsistent with description of the datasheet
       but the guest could receive a packet by the next procedure.
  o Host3
     Host3# ifconfig eth1 add 3ffd:5::ab/64
     Host3# ping6 -c1 3ffd:5::aa
 
  We could ping to the guest with new IPv6 address and keep on pinging to 3ffe:5::fe.



I think I could add new multicast MAC filter "after transmit and receive are enabled".
The question is whether there is any issue with the above usage.


Regards,
Madoka

------------------------------------------------------------------------------
Put Bad Developers to Shame
Dominate Development with Jenkins Continuous Integration
Continuously Automate Build, Test & Deployment 
Start a new project now. Try Jenkins in the cloud.
http://p.sf.net/sfu/13600_Cloudbees
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
