From: gerrit@erg.abdn.ac.uk
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
     negotiation
Date: Mon, 15 Dec 2008 16:25:46 -0000 (GMT)
Message-ID: <36660.148.187.160.35.1229358346.squirrel@148.187.160.35>
References: <20081208.011917.176472177.davem@davemloft.net>
    <1229175685-18716-1-git-send-email-gerrit@erg.abdn.ac.uk>
    <1229175685-18716-2-git-send-email-gerrit@erg.abdn.ac.uk>
    <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
    <e2d7436a0812130555r52422bel1dd9b66ba8479e2a@mail.gmail.com>
    <20081213145655.GA14240@gerrit.erg.abdn.ac.uk>
    <e2d7436a0812140650r41b601dfgc3bbf41f01c2bb5d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: =?iso-8859-1?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:34271 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753230AbYLOQ1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 11:27:05 -0500
In-Reply-To: <e2d7436a0812140650r41b601dfgc3bbf41f01c2bb5d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Since the lock is dropped after checking ccids[id] then there's
> a window where multiple request_module()s can be called if multiple
> applications create a DCCP socket at a same time. The code below
> should do the same without a lock (ccids is a static array,
> so ccids[N] is always at the same place).
>
> static int ccid_request_module(u8 id)
> {
>        if (!in_atomic()) {
>                rmb();
>                if (ccids[id] == NULL)
>                        return request_module("net-dccp-ccid-%d", id);
>        }
>        return 0;
> }
>
I think that the code (not yours) is in general misleading. It stems from
an earlier phase of the DCCP development. Now, with the present patch set,
the rationale is
 * all CCIDs that are advertised must be loaded
 * this is a subset of the configured CCIDs and contains at least one CCID
 * the request_module is only ever executed once, when the first DCCP
   application tries to pre-load the CCIDs it wants to advertise

Hence I think we have a chance by going completely lockless here, by
loading all configured CCIDs at runtime. In this manner the per-connection
check "are all advertised CCIDs are loaded?" falls under the table, we
do not need to worry about concurrent access, and loading DCCP implies that
all needed CCIDs are there.

Arnaldo would you be okay with such an approach ? I would be willing to
revise the patch set accordingly.

Gerrit

