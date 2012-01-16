From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 3/6] netback: switch to NAPI + kthread
 model
Date: Mon, 16 Jan 2012 11:46:03 +0000
Message-ID: <4F140DFB.60009@citrix.com>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>	 <1326473949-22389-4-git-send-email-wei.liu2@citrix.com>	 <4F107625.7090601@citrix.com> <1326706394.5285.5.camel@liuw-desktop>	 <1326710711.17210.411.camel@zakaz.uk.xensource.com>	 <291EDFCB1E9E224A99088639C4762022B5991BEC4D@LONPMAILBOX01.citrite.net> <1326712173.17210.412.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Durrant <Paul.Durrant@citrix.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:32376 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753555Ab2APLqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jan 2012 06:46:06 -0500
In-Reply-To: <1326712173.17210.412.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/01/12 11:09, Ian Campbell wrote:
> I think you'd want to keep moving the event pointer to
> handle wrap around, i.e. by keeping it always either far enough away or
> right behind. (I think "req_cons - 1" is probably the correct option
> BTW).

When using RING_FINAL_CHECK_FOR_REQUESTS() as-is you will get an
additional spurious event every 4 billion events.

Something like this would fix it.

#define RING_FINAL_CHECK_FOR_REQUESTS(_r, _work_to_do) do {
    (_work_to_do) = RING_HAS_UNCONSUMED_REQUESTS(_r);
    if (_work_to_do) {
        /* ensure req_event is always in the past to avoid spurious
           interrupt on wrap-around. */
        (_r)->sring->req_event = (_r)->req_cons;
        break;
    }
    (_r)->sring->req_event = (_r)->req_cons + 1;
    mb();
    (_work_to_do) = RING_HAS_UNCONSUMED_REQUESTS(_r);
} while (0)

And similarly for RING_FINAL_CHECK_FOR_RESPONSES().

David
