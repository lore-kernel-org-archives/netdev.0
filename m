From: John Heffner <jheffner@psc.edu>
Subject: A case AGAINST checksum offload
Date: Fri, 12 Nov 2004 18:46:11 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Currently with many common Ethernet devices in Linux, hardware TCP
checksumming is enabled by default.  This seems fairly dangerous to me.
Most link layer checksums are much stronger than the TCP/UDP checksum;
most bit errors are caught by these.  However, one of the primary purposes
of the TCP/UDP checksum is to detect errors occurring outside the
protection of the link layer checksums -- errors when data is reassembled
or copied across busses inside hosts and routers.  Hardware checksum
offload removes the ability to detect errors between the NIC and host
memory.

For some anecdotal evidence: One of my machines has fiber e1000 (82545GM)
and I observed corruptions in its TCP streams.  I actually caught this
because large SSH flows originating from this host would usually die after
<1 GB or so with a MAC error, indicating the TCP stream was somehow
corrupt.  I looked at some TCP statistics, which indicated no dropped
packets or checksum errors, but then I realized hardware checksumming was
on.  I turned off hardware checksumming and found the stream errors
disappeared, and it correctly started discarding the corrupt TCP segments.
Luckily for me, this machine is mainly used for testing, and the strong
authentication SSH uses caught the problems.

Though I don't have any definitive references, I've heard stories that Sun
turned off UDP checksums on LANs to increase NFS performance, only to
re-enable checksumming by default after problems similar to mine caused
corruptions of some critical databases.

Since TCP checksum offload should only really helps the zero-copy case in
terms of performance, it seems safer to turn off hardware checksumming by
default, or perhaps only enable it if an application is doing a zero-copy
send.

  -John
