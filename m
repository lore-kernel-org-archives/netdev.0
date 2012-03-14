From: Justin Gibbs <justing@spectralogic.com>
Subject: Re: [Xen-devel] [PATCH 0001/001] xen: multi page ring support for
	block devices
Date: Wed, 14 Mar 2012 17:01:09 +0000
Message-ID: <59150D7B-8349-4249-A93A-04883F4AD744@spectralogic.com>
References: <1330701099-18281-1-git-send-email-santoshprasadnayak@gmail.com>
	<7914B38A4445B34AA16EB9F1352942F1010A1FA12364@SJCPMAILBOX01.citrite.net>
	<CAPbh3rsExLtohBwVd_scYuO=GN1iZE5egQQ3x5M59YUno5Rtyw@mail.gmail.com>
	<4F5739760200007800076DA6@nat28.tlf.novell.com>
	<230A793A-C929-468E-97BE-1C68920749E1@spectralogic.com>
	<4F60C888020000780007861F@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "jeremy@goop.org" <jeremy@goop.org>, Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"waldi@debian.org" <waldi@debian.org>,
	"joe.jin@oracle.com" <joe.jin@oracle.com>,
	"weiyi.huang@gmail.com" <weiyi.huang@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	DavidVrabel <david.vrabel@citrix.com>,
	Santosh Jodh <Santosh.Jodh@citrix.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"<konrad@darnok.org>" <konrad@darnok.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"xen-devel@lists.xen.or
To: Jan Beulich <JBeulich@suse.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4F60C888020000780007861F@nat28.tlf.novell.com>
Content-Language: en-US
Content-ID: <E4E9B66CD1AFDA4AADC65DF5542C5952@spectralogic.com>
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

On Mar 14, 2012, at 9:34 AM, Jan Beulich wrote:

>>>> On 14.03.12 at 07:32, Justin Gibbs <justing@spectralogic.com> wrote:
>> There's another problem here that I brought up during the Xen
>> Hack-a-thon.  The ring macros require that the ring element count
>> be a power of two.  This doesn't mean that the ring will be a power
>> of 2 pages in size.  To illustrate this point, I modified the FreeBSD
>> blkback driver to provide negotiated ring stats via sysctl.
>> 
>> Here's a connection to a Windows VM running the Citrix PV drivers:
>> 
>>    dev.xbbd.2.max_requests: 128
>>    dev.xbbd.2.max_request_segments: 11
>>    dev.xbbd.2.max_request_size: 45056
>>    dev.xbbd.2.ring_elem_size: 108  <= 32bit ABI
>>    dev.xbbd.2.ring_pages: 4
>>    dev.xbbd.2.ring_elements: 128
>>    dev.xbbd.2.ring_waste: 2496
>> 
>> Over half a page is wasted when ring-page-order is 2.  I'm sure you
>> can see where this is going.  :-)
> 
> Having looked a little closer on how the wasted space is progressing,
> I find myself in the odd position that I can't explain the original (and
> still active) definition of BLKIF_MAX_SEGMENTS_PER_REQUEST (11):
> With ring-order zero, there's 0x240/0x1c0 bytes (32/64-bit
> respectively) are unused. With 32 requests fitting in the ring, and with
> each segment occupying 6 bytes (padded to 8), in the 64-bit variant
> there's enough space for a 12th segment (32-bit would even have
> space for a 13th). Am I missing anything here?

I don't profess to know the real reason, but the only thing I can come up
with is a requirement/desire on some platforms for 16byte alignment
of the request structures.  This would make the largest possible structure
112 bytes, not the 120 that would allow for more elements.

While we're talking about fixing ring data structures, can RING_IDX
be defined as a "uint32_t" instead of "unsigned int".  The structure
padding in the ring macros assumes RING_IDX is exactly 4 bytes,
so this should be made explicit.  ILP64 machines may still be a way
out, but the use of non-fixed sized types in places where size really
matters just isn't clean.

> 
>> Here are the limits published by our backend to the XenStore:
>> 
>>    max-ring-pages = "113"
>>    max-ring-page-order = "7"
>>    max-requests = "256"
>>    max-request-segments = "129"
>>    max-request-size = "524288"
> 
> Oh, so this protocol doesn't require ring-pages (and max-ring-pages)
> to be a power of two? In which case I think it is a mistake to also
> advertise max-ring-page-order, as at least the (Linux) frontend code
> I know of interprets this as being able to set up a ring of (using the
> numbers above) 128 pages (unless, of course, your backend can deal
> with this regardless of the max-ring-pages value it announces).

The advertised max-ring-pages is sufficient to hold the maximum allowed
number of ring elements regardless of ABI.  This is then rounded up to the
next power of 2 pages to get the max-ring-page order.  When the front-end
negotiates, the backend just verifies that the maximum number of ring
elements in the specified ring size doesn't exceed the backend's limit.
Fortunately, even with this large of a ring, regardless of ABI, a given
page order computes to the same number of ring elements.  You just have
more wasted space.

--
Justin
