From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [Fwd: [Bug 5644] New: NFS v3 TCP 3-way handshake incorrect,
	iptables blocks access]
Date: Wed, 23 Nov 2005 12:51:16 -0500
Message-ID: <1132768276.8016.31.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-HxutDEdB/BdGYWP1LENI"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-HxutDEdB/BdGYWP1LENI
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Sorry to be cross-posting, but does this bug ring any bells? I'm having
trouble seeing how the sunrpc server code could be at fault.

Cheers,
  Trond

--=-HxutDEdB/BdGYWP1LENI
Content-Disposition: inline
Content-Description: Forwarded message - [Bug 5644] New: NFS v3 TCP 3-way
	handshake incorrect, iptables blocks access
Content-Type: message/rfc822

Return-Path: <www@osdl.org>
Received: from mail-imap3.uio.no ([unix socket]) by mail-imap3.uio.no
	(Cyrus v2.2.10) with LMTPA; Wed, 23 Nov 2005 17:04:06 +0100
X-Sieve: CMU Sieve 2.2
Delivery-date: Wed, 23 Nov 2005 17:04:06 +0100
Received: from mail-mx2.uio.no ([129.240.10.30]) by mail-imap3.uio.no with
	esmtp (Exim 4.43) id 1Eex6M-0001jD-QY for trond.myklebust@fys.uio.no; Wed,
	23 Nov 2005 17:04:06 +0100
Received: from smtp.osdl.org ([65.172.181.4]) by mail-mx2.uio.no with
	esmtps (TLSv1:DES-CBC3-SHA:168) (Exim 4.43) id 1Eex6D-0005HH-3p for
	trond.myklebust@fys.uio.no; Wed, 23 Nov 2005 17:03:57 +0100
Received: from fire-2.osdl.org (localhost [127.0.0.1]) by smtp.osdl.org
	(8.12.8/8.12.8) with ESMTP id jANG3rnO026282 (version=TLSv1/SSLv3
	cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO) for
	<trond.myklebust@fys.uio.no>; Wed, 23 Nov 2005 08:03:53 -0800
Received: (from www@localhost) by fire-2.osdl.org (8.12.8/8.12.5/Submit) id
	jANG3qDT026280; Wed, 23 Nov 2005 08:03:52 -0800
Date: Wed, 23 Nov 2005 08:03:52 -0800
Message-Id: <200511231603.jANG3qDT026280@fire-2.osdl.org>
From: bugme-daemon@bugzilla.kernel.org
To: trond.myklebust@fys.uio.no
Subject: [Bug 5644] New: NFS v3 TCP 3-way handshake incorrect, iptables
	blocks access
X-Bugzilla-Reason: AssignedTo
X-Bugzilla-Category: File System
X-Bugzilla-Component: NFS
Received-SPF: pass (localhost is always allowed.)
X-Spam-Status: No, hits=1.088 required=5 tests=NO_REAL_NAME
X-Spam-Level: *
X-Spam-Checker-Version: SpamAssassin 2.63-osdl_revision__1.56__
X-MIMEDefang-Filter: osdl$Revision: 1.127 $
X-Scanned-By: MIMEDefang 2.36
X-MailScanner-Information: This message has been scanned for viruses/spam.
	Contact postmaster@uio.no if you have questions about this scanning
X-UiO-MailScanner: No virus found
X-UiO-Spam-info: not spam, SpamAssassin (score=0.178, required 12,
	autolearn=disabled, NO_REAL_NAME 0.18)
Mime-Version: 1.0
Status: RO
Content-Length: 2275
X-UID: 7175
X-Keywords: 
Content-Transfer-Encoding: 7bit

http://bugzilla.kernel.org/show_bug.cgi?id=5644

           Summary: NFS v3 TCP 3-way handshake incorrect, iptables blocks
                    access
    Kernel Version: 2.6.14
            Status: NEW
          Severity: blocking
             Owner: trond.myklebust@fys.uio.no
         Submitter: jl-icase@comcast.net


Most recent kernel where this bug did not occur:
Distribution: Can't remember, possibly FC2.
Hardware Environment:
Software Environment:
Problem Description:

Steps to reproduce:
1. Boot NFS v3 TCP client running iptables & mount NFS filesystem
2. Do a normal NFS client reboot & try mounting the same filesystem again
3. Experience intermittent failure to read superblock

The cause of this problem is NFS server's improper response to SYN packet sent
by the client.  This occurs *after* successful client authorization, when the
client tries to open the connection (i.e. sends SYN to the server's nfs port) to
read the superblock.  The server (sometimes) responds with a pure ACK without
the SYN bit set.  This is blocked by iptables -- thus, mount fails with a "could
not read superblock" message.

Here is an excerpt from ethereal log:

      3 0.021733    client           SERVER           TCP      800 > nfs [SYN]
Seq=0 Ack=0 Win=5840 Len=0 MSS=1460 TSV=24095 TSER=0 WS=2
      4 0.021846    SERVER           client           TCP      nfs > 800 [ACK]
Seq=9138391 Ack=3580883479 Win=16022 Len=0 TSV=244936050 TSER=1149400
      5 0.021864    client           SERVER           ICMP     Destination
unreachable (Host administratively prohibited)

The above problem occurs with a very simple default+ssh iptables configuration.
 Disabling iptables on the client makes the problem go away.  Even with iptables
active, there is no problem when nfsd responds with a proper [SYN,ACK] instead
of just pure ACK (this happens intermittently after the client reboot).

Please fix nfsd so that it reliably responds to SYN packets with proper
[SYN,ACK] packets instead of just ACK packets.  Apparently, nfsd state doesn't
get properly reset on client reboots.  Other people have reported autofs
failures which may be related (e.g. on remounts).

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.

--=-HxutDEdB/BdGYWP1LENI--
