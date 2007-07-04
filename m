From: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Subject: checksum of lsrr
Date: Wed, 04 Jul 2007 22:28:24 +0900 (JST)
Message-ID: <20070704.222824.74749937.chamas@h4.dion.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm05mta.dion.ne.jp ([219.125.112.5]:4361 "HELO
	nm05omta055.dion.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757152AbXGDNnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 09:43:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I tried source routing with netcat just for my interest but it did
not work. tcpdump output follows:

00:07:40:53:bd:55 > 00:01:8e:b3:82:1c, ethertype IPv4 (0x0800),
  length 86: (tos 0x0, ttl  64, id 50437, offset 0, flags [DF],
  proto: TCP (6), length: 72, options (LSRR 172.27.129.2 172.27.129.2,NOP))
  172.27.129.129.44281 > 172.27.129.1.3333:
  S, cksum 0xc434 (correct), 561806820:561806820(0) win 5840 <mss 1460,sackOK,timestamp 112865 0,nop,wscale 6>

00:01:8e:b3:82:1c > 00:e0:81:29:d1:7d, ethertype IPv4 (0x0800),
  length 86: (tos 0x0, ttl  63, id 50437, offset 0, flags [DF],
  proto: TCP (6), length: 72, options (LSRR 172.27.129.1, 172.27.129.2,NOP))
  172.27.129.129.44281 > 172.27.129.2.3333:
  S, cksum 0xc434 (correct), 561806820:561806820(0) win 5840 <mss 1460,sackOK,timestamp 112865 0,nop,wscale 6>

00:e0:81:29:d1:7d > 00:01:8e:b3:82:1c, ethertype IPv4 (0x0800),
  length 82: (tos 0x0, ttl  64, id 0, offset 0, flags [DF],
  proto: TCP (6), length: 68, options (LSRR 172.27.129.129,EOL))
  172.27.129.2.3333 > 172.27.129.1.44281:
  S, cksum 0xc35b (correct), 183283162:183283162(0) ack 561806821 win 5792 <mss 1460,sackOK,timestamp 673831 112865,nop,wscale 6>

00:01:8e:b3:82:1c > 00:07:40:53:bd:55, ethertype IPv4 (0x0800),
  length 82: (tos 0x0, ttl  63, id 0, offset 0, flags [DF],
  proto: TCP (6), length: 68, options (LSRR 172.27.129.1,,EOL))
  172.27.129.2.3333 > 172.27.129.129.44281:
  S, cksum 0xc35b (incorrect (-> 0xc3db), 183283162:183283162(0) ack 561806821 win 5792 <mss 1460,sackOK,timestamp 673831 112865,nop,wscale 6>

the last line says checksum is incorrect, then I saw
ip_options_rcv_rcv_srr() in ip_options.c:

		memcpy(&iph->daddr, &optptr[srrptr-1], 4);
		opt->is_changed = 1;
	}
	if (srrptr <= srrspace) {

if we change destination address, we need recompute not only ip
checksum but also tcp's, don't we? 

thanks,
