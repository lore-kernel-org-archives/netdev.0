From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] GRO scalability
Date: Fri, 05 Oct 2012 16:52:27 +0200
Message-ID: <1349448747.21172.113.camel@edumazet-glaptop>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
	 <1348769294.5093.1566.camel@edumazet-glaptop>
	 <1348769990.5093.1584.camel@edumazet-glaptop>
	 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
	 <1348841041.5093.2477.camel@edumazet-glaptop>
	 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39102 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755257Ab2JEOwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 10:52:32 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so978000bkc.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 07:52:31 -0700 (PDT)
In-Reply-To: <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current GRO cell is somewhat limited :

- It uses a single list (napi->gro_list) of pending skbs

- This list has a limit of 8 skbs (MAX_GRO_SKBS)

- Workloads with lot of concurrent flows have small GRO hit rate but
  pay high overhead (in inet_gro_receive())

- Increasing MAX_GRO_SKBS is not an option, because GRO
  overhead becomes too high.

- Packets can stay a long time held in GRO cell (there is
  no flush if napi never completes on a stressed cpu)

  Some elephant flows can stall interactive ones (if we receive
  flood of non TCP frames, we dont flush tcp packets waiting in
gro_list)

What we could do :

1) Use a hash to avoid expensive gro_list management and allow
   much more concurrent flows.

Use skb_get_rxhash(skb) to compute rxhash

If l4_rxhash not set -> not a GRO candidate.

If l4_rxhash set, use a hash lookup to immediately finds a 'same flow'
candidates.

(tcp stack could eventually use rxhash instead of its custom hash
computation ...)

2) Use a LRU list to eventually be able to 'flush' too old packets,
   even if the napi never completes. Each time we process a new packet,
   being a GRO candidate or not, we increment a napi->sequence, and we
   flush the oldest packet in gro_lru_list if its own sequence is too
   old.

  That would give a latency guarantee.
