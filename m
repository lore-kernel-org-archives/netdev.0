From: Karl Heiss <kheiss@gmail.com>
Subject: IPSEC: tunnel breakage with out-of-order IPv4 fragments
Date: Thu, 10 Jul 2014 10:57:21 -0400
Message-ID: <CAGugRbVWyTM2J0Fyw1Cq1byqfjZBy_EFLSShqVdzxYZmmUWK_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:58677 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbaGJO5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 10:57:22 -0400
Received: by mail-ie0-f177.google.com with SMTP id at20so1055199iec.36
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 07:57:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe I have found an issue whereby IPv4 fragments arriving
out-of-order will cause an IPSEC tunnel to stop passing any traffic
which arrived fragmented, citing 'SA-icv-failure'.  Packets which were
not fragmented will validate and pass successfully, even once the
condition has been triggered.  I have decrypted the traffic and have
verified that the traffic is arriving correctly.  It appears as if the
condition persists until all connections are closed.

The issue was originally discovered in RHEL 6.5 (2.6.32-431.11.2.el6)
kernel and verified with Fedora 20 running 3.15.0-rc8-nn on x86_64.

The easiest way I have found to reproduce the issue is to use a kernel
without commit c08751c851b78514f6ec5 (Fix data chunk fragmentation for
MTU values which are not multiple of 4) to generate fragmented SCTP
traffic using multiple single-homed connections.  This can be easily
done by running the following command a few times (in parallel) on the
traffic generator:

    dd if=/dev/zero bs=4096 count=100000 | ncat -d 0.02 --sctp -s
<local_ip> <remote_ip> 60000

On the remote end, setup a listener:

    ncat --sctp -l -k -p 60000 > /dev/null

At this point, you should be able to see audit.log errors to the effect of:

type=MAC_IPSEC_EVENT msg=audit(1404931490.964:872): op=SA-icv-failure
src=10.240.34.75 dst=10.240.34.85 spi=101378814(0x60aeafe) seqno=38605
type=MAC_IPSEC_EVENT msg=audit(1404931490.964:873): op=SA-icv-failure
src=10.240.34.75 dst=10.240.34.85 spi=101378814(0x60aeafe) seqno=38607
type=MAC_IPSEC_EVENT msg=audit(1404931490.964:874): op=SA-icv-failure
src=10.240.34.75 dst=10.240.34.85 spi=101378814(0x60aeafe) seqno=38606

I have packet captures and matching audit logs for those interested.
Any help would be greatly appreciated.

Regards,
Karl
