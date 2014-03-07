From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/6] Drivers: net: hyperv: Enable scatter gather I/O
Date: Fri, 07 Mar 2014 16:47:56 -0500 (EST)
Message-ID: <20140307.164756.1488071770631289333.davem@davemloft.net>
References: <1394170320-1002-1-git-send-email-kys@microsoft.com>
 <1394170361-1043-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394170361-1043-1-git-send-email-kys@microsoft.com>
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

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Thu,  6 Mar 2014 21:32:36 -0800

> +static u32 fill_pg_buf(struct page *page, u32 offset, u32 len,
> +			struct hv_page_buffer *pb)
> +{
> +	int j = 0;
> +
> +	/* Deal with compund pages by ignoring unused part
> +	 * of the page.
> +	 */
> +	page += offset  >> PAGE_SHIFT;

Please only one space between "offset" and ">>"

> +	offset &= ~PAGE_MASK;
> +
> +	while (len > 0) {
> +		unsigned long bytes;
> +
> +		bytes = PAGE_SIZE - offset;
> +		if (bytes > len)
> +			bytes = len;
> +		pb[j].pfn = page_to_pfn(page);
> +		pb[j].offset = offset;
> +		pb[j].len = bytes;
> +
> +		offset += bytes;
> +		len -= bytes;
> +
> +		if (offset == PAGE_SIZE && len) {
> +			page++;
> +			offset = 0;
> +			j++;
> +		}
> +	}
> +
> +	return j + 1;
> +}

I think this function has some edge case errors.

As I understand it, this function returns how many page buffer entries
were filled in.

But if we fill exactly the end of a page, we will report one too many
in the return value.

Consider an "offset" of X, where X is smaller than PAGE_SIZE.  And a
"len" which is exactly "PAGE_SIZE - offset".

We will fill in exactly one page buffer entry, however we will
erroneously return 2 from this function.

I believe the fix is to first replace the test at the end of the loop
with:

	page++;
	offset = 0;
	j++;

And subsequently change the function to just return plain "j".
