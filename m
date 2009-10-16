From: Steve French <smfrench@gmail.com>
Subject: TCP_NODELAY and CORK - should they be added for network fs case?
Date: Fri, 16 Oct 2009 09:53:15 -0500
Message-ID: <524f69650910160753t2e762b9bqaa69cd3041b58034@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f171.google.com ([209.85.216.171]:63638 "EHLO
	mail-px0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932585AbZJPOxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 10:53:51 -0400
Received: by pxi1 with SMTP id 1so259968pxi.33
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 07:53:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking at calls to kernel_sendmsg, and thinking about why I only see
a few places that do TCP_NODELAY and TCP_CORK in kernel.

Looking at the cifs example.  cifs is trying to send packets which
vary from about 50-100 bytes for common calls (like lookup) to about
56K for file writes (can be larger if override wsize and max buffer
size via insmod parameter), and cifs always uses kernel_sendmsg.   For
the cifs case, sending individual SMB/CIFS requests to a particular
server (socket) are serialized, protected by a mutex, even if many
processes are writing to different remote files at one time.
Usually one kernel_sendmsg is all that is needed to send an SMB
request - does kernel_sendmsg implicitly "cork" the request so that
the SMB is not unnecessarily fragmented?  If the socket is full, and
only a few bytes are sent, multiple sendmsg's may be required to send
one smb - should cifs be doing a cork before the loop which calls
kernel_sendmsg in smb_sendv in fs/cifs/transport.c and uncork
afterward (since the server can't do much processing without getting
the whole SMB request except in one narrow case of receivefile on
certain write requests)?    Especially if we add code to allow setting
"TCP_NODELAY" ... to improve GigE performance

Are there any cases where we should be setting LOWDELAY instead for
this kind of socket?

-- 
Thanks,

Steve
