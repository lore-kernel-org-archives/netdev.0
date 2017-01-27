From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Fri, 27 Jan 2017 10:11:19 -0500
Message-ID: <20170127151119.GB25829@oracle.com>
References: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-KXqpODBVQ0vUt1a1p_mMXzzQp=5GU33f9GY9_cbPJxDw@mail.gmail.com>
 <20170126213742.GE29475@oracle.com>
 <CAF=yD-L66dFV64fx21A3059LRiot_-j0Ykp9GkRFwf52099upQ@mail.gmail.com>
 <20170127020836.GH29475@oracle.com>
 <CAF=yD-LWLDQhQMBA9O5T5k+di5VKMPtix+pHLb-zjUtd4+WZmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:36403 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932871AbdA0PMr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 10:12:47 -0500
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v0RFCXlQ000779
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 15:12:33 GMT
Content-Disposition: inline
In-Reply-To: <CAF=yD-LWLDQhQMBA9O5T5k+di5VKMPtix+pHLb-zjUtd4+WZmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/27/17 09:37), Willem de Bruijn wrote:
> The immediate problem you were facing is that dev_validate_header
> accepts values smaller than hard_header_len even for protocols with
> fixed header lengths.

Yes!

> This is a consequence of that CAP_SYS_RAWIO branch. Without it,
> dev_validate_header would have correctly dropped your packet. That
> branch was added because there are tests that explicitly test bad
> input. Ideally, it would be behind sysctl and static key, but doing so
> might start failing active tests.

so this is quite perplexing to someone not familiar with ax25-like
interfaces.  In addition to the pointer you shared, I see
  https://www.spinics.net/lists/netdev/msg367358.html
where the quote is

" The AX.25 device level drivers are simply written to be robust if
  thrown partial frames.
   :
  The other thing that concerns me about this added logic in general is
  that you are also breaking test tools that want to deliberately send
  corrupt frames to certain classes of interface."

But how does the driver (even a robust one!) compute the L2 dst/src if the
application has not even passed down the minimum (which is 21 for ax25?)

Would it make sense to only do the CAP_SYS_RAWIO branch if the 
driver declares itself to have variable length L2 headers, via, e.g.,
some priv flag?

--Sowmini

BTW the http://comments.gmane.org/gmane.linux.network/401064 referred
to in commit 2793a23 is not accessible any more, not sure if its contents
were the same as the link you just shared.
