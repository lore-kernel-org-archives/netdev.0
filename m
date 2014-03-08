From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V2 1/6] Drivers: net: hyperv: Enable scatter gather I/O
Date: Sat, 8 Mar 2014 10:27:54 +0000
Message-ID: <c72c0d17b4bd405cb218ab09b1c2e77e@BY2PR03MB299.namprd03.prod.outlook.com>
References: <1394170361-1043-1-git-send-email-kys@microsoft.com>
 <20140307.164756.1488071770631289333.davem@davemloft.net>
 <fd6bb08bd9a447aa9c0da3b584ea9bb8@BY2PR03MB299.namprd03.prod.outlook.com>
 <20140308.013658.918013334851017662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140308.013658.918013334851017662.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, March 8, 2014 12:07 PM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH V2 1/6] Drivers: net: hyperv: Enable scatter gather I/O
> 
> From: KY Srinivasan <kys@microsoft.com>
> Date: Sat, 8 Mar 2014 04:12:01 +0000
> 
> >
> >
> >> -----Original Message-----
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Saturday, March 8, 2014 3:18 AM
> >> To: KY Srinivasan
> >> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> >> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> >> jasowang@redhat.com
> >> Subject: Re: [PATCH V2 1/6] Drivers: net: hyperv: Enable scatter
> >> gather I/O
> >>
> >> From: "K. Y. Srinivasan" <kys@microsoft.com>
> >> Date: Thu,  6 Mar 2014 21:32:36 -0800
> >>
> >> > +static u32 fill_pg_buf(struct page *page, u32 offset, u32 len,
> >> > +			struct hv_page_buffer *pb)
> >> > +{
> >> > +	int j = 0;
> >> > +
> >> > +	/* Deal with compund pages by ignoring unused part
> >> > +	 * of the page.
> >> > +	 */
> >> > +	page += offset  >> PAGE_SHIFT;
> >>
> >> Please only one space between "offset" and ">>"
> >>
> >> > +	offset &= ~PAGE_MASK;
> >> > +
> >> > +	while (len > 0) {
> >> > +		unsigned long bytes;
> >> > +
> >> > +		bytes = PAGE_SIZE - offset;
> >> > +		if (bytes > len)
> >> > +			bytes = len;
> >> > +		pb[j].pfn = page_to_pfn(page);
> >> > +		pb[j].offset = offset;
> >> > +		pb[j].len = bytes;
> >> > +
> >> > +		offset += bytes;
> >> > +		len -= bytes;
> >> > +
> >> > +		if (offset == PAGE_SIZE && len) {
> >> > +			page++;
> >> > +			offset = 0;
> >> > +			j++;
> >> > +		}
> >> > +	}
> >> > +
> >> > +	return j + 1;
> >> > +}
> >>
> >> I think this function has some edge case errors.
> >>
> >> As I understand it, this function returns how many page buffer
> >> entries were filled in.
> >>
> >> But if we fill exactly the end of a page, we will report one too many
> >> in the return value.
> >
> > I may be missing something here; but in the case you are describing we
> > would return a value of one as we should. When offset + len is exactly
> > equal to the page size, we would not increment the value of j, since
> > at that point len == 0. Since the initial value of j was 0 and we return (j + 1),
> we will return 1.
> 
> That's not what happens, you execute the loop code at least once, and
> hit:
> 
> >> > +		offset += bytes;
> >> > +		len -= bytes;
> >> > +		if (offset == PAGE_SIZE && len) {
> >> > +			page++;
> >> > +			offset = 0;
> >> > +			j++;
> >> > +		}

> 
> thus incrementing j before the return statement.

I don't mean to be argumentative, but I still don't see the issue here. You are right, I
will execute the loop code at least once, but j gets incremented only if len is non-zero as well as
offset being == PAGE_SIZE. "len" would have gotten decremented prior to the check and in the case
we are talking about, "len" would be zero and so j would not get incremented.

Regards,

K. Y
