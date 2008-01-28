From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH 3/6] [DCCP]: Bug-Fix - AWL was never updated
Date: Tue, 29 Jan 2008 06:59:18 +1300
Message-ID: <5640c7e00801280959k456fd080l3f29953c0d74eb16@mail.gmail.com>
References: <1201515376-8280-1-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1201515376-8280-2-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1201515376-8280-3-git-send-email-gerrit@erg.abdn.ac.uk>
	 <1201515376-8280-4-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:7821 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbYA1R7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 12:59:21 -0500
Received: by wa-out-1112.google.com with SMTP id v27so3124057wah.23
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 09:59:19 -0800 (PST)
In-Reply-To: <1201515376-8280-4-git-send-email-gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 28, 2008 11:16 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This patch was triggered by finding the  following message in the syslog:
>  "kernel: dccp_check_seqno: DCCP: Step 6 failed for DATAACK packet, [...]
>    P.ackno exists or LAWL(82947089) <= P.ackno(82948208)
>                                     <= S.AWH(82948728), sending SYNC..."
>
> Note the difference between AWH and AWL: it is 1639 packets (while Sequence
> Window was actually at 100). A closer look at the trace showed that
> LAWL = AWL = 82947089 equalled the ISS on the Response.
>
> The cause of the bug was that AWL was only ever set on the first packet - the
> DCCP-Request sent by dccp_v{4,6}_connect().
>
> The fix is to continually update AWL/AWH with each new packet (as GSS=AWH).
>
> In addition, AWL/AWH are now updated to enforce more stringent checks on the
> initial sequence numbers when connecting:
>  * AWL is initialised to ISS and remains at this value;
>  * AWH is always set to GSS (via dccp_update_gss());
>  * so on the first Request: AWL =      AWH = ISS,
>    and on the n-th Request: AWL = ISS, AWH = ISS+n.
>
> As a consequence, only Response packets that refer to Requests sent by this
> host will pass, all others are discarded. This is the intention and in effect
> implements the initial adjustments for AWL as specified in RFC 4340, 7.5.1.
>
> Note: A problem that remains is that ISS can potentially be under-run even after
>       the initial handshake; this is addressed a subsequent patch.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Yes I had seen this and had worked out that variables weren't being
updated as they should be but hadn't got as far as a fix before I
stopped my coding days so much :-(

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
