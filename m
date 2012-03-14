From: Justin Gibbs <justing@spectralogic.com>
Subject: Re: [Xen-devel] [PATCH 0001/001] xen: multi page ring support for
	block devices
Date: Wed, 14 Mar 2012 06:32:55 +0000
Message-ID: <230A793A-C929-468E-97BE-1C68920749E1@spectralogic.com>
References: <1330701099-18281-1-git-send-email-santoshprasadnayak@gmail.com>
	<7914B38A4445B34AA16EB9F1352942F1010A1FA12364@SJCPMAILBOX01.citrite.net>
	<CAPbh3rsExLtohBwVd_scYuO=GN1iZE5egQQ3x5M59YUno5Rtyw@mail.gmail.com>
	<4F5739760200007800076DA6@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "jeremy@goop.org" <jeremy@goop.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"waldi@debian.org" <waldi@debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"joe.jin@oracle.com" <joe.jin@oracle.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"weiyi.huang@gmail.com" <weiyi.huang@gmail.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Santosh Jodh <Santosh.Jodh@citrix.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"<konrad@darnok.org>" <konrad@darnok.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualizati
To: Jan Beulich <JBeulich@suse.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4F5739760200007800076DA6@nat28.tlf.novell.com>
Content-Language: en-US
Content-ID: <FDFA958FB04A0E439CDD2091E5CD7AA7@spectralogic.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


On Mar 7, 2012, at 2:33 AM, Jan Beulich wrote:

>>>> On 06.03.12 at 18:20, Konrad Rzeszutek Wilk <konrad@darnok.org> wrote:
>> -> XENBUS_MAX_RING_PAGES - why 2? Why not 4? What is the optimal
>> default size for SSD usage? 16?
> 
> What do SSDs have to do with a XenBus definition? Imo it's wrong (and
> unnecessary) to introduce a limit at the XenBus level at all - each driver
> can do this for itself.
> 
> As to the limit for SSDs in the block interface - I don't think the number
> of possibly simultaneous requests has anything to do with this. Instead,
> I'd expect the request number/size/segments extension that NetBSD
> apparently implements to possibly have an effect.
> 
> Jan

There's another problem here that I brought up during the Xen
Hack-a-thon.  The ring macros require that the ring element count
be a power of two.  This doesn't mean that the ring will be a power
of 2 pages in size.  To illustrate this point, I modified the FreeBSD
blkback driver to provide negotiated ring stats via sysctl.

Here's a connection to a Windows VM running the Citrix PV drivers:

    dev.xbbd.2.max_requests: 128
    dev.xbbd.2.max_request_segments: 11
    dev.xbbd.2.max_request_size: 45056
    dev.xbbd.2.ring_elem_size: 108  <= 32bit ABI
    dev.xbbd.2.ring_pages: 4
    dev.xbbd.2.ring_elements: 128
    dev.xbbd.2.ring_waste: 2496

Over half a page is wasted when ring-page-order is 2.  I'm sure you
can see where this is going.  :-)

Here are the limits published by our backend to the XenStore:

    max-ring-pages = "113"
    max-ring-page-order = "7"
    max-requests = "256"
    max-request-segments = "129"
    max-request-size = "524288"

Because we allow so many concurrent, large requests in our product,
the ring wastage really adds up if the front end doesn't support
the "ring-pages" variant of the extension.  However, you only need
a ring-page-order of 3 with this protocol to start seeing pages of
wasted ring space.

You don't really want to negotiate "ring-pages" either.  The backends
often need to support multiple ABIs.  I can easily construct a set
of limits for the FreeBSD blkback driver which will cause the ring
limits to vary by a page between the 32bit and 64bit ABIs.

With all this in mind, the backend must do a dance of rounding up,
taking the max of the ring sizes for the different ABIs, and then
validating the front-end published limits taking its ABI into
account.  The front-end does some of this too.  Its way too messy
and error prone because we don't communicate the ring element limit
directly.

"max-ring-element-order" anyone? :-)

--
Justin
