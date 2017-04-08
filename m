From: Paul Fiterau Brostean <p.fiterau-brostean@science.ru.nl>
Subject: Non-standard TCP stack processing of packets with unacceptable ACK
 numbers
Date: Sat, 8 Apr 2017 22:29:02 +0200
Message-ID: <fbb92f49-5eca-f411-dcab-253d2a222623@science.ru.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------161CC05030E03164F98EFF8D"
Cc: Frits Vaandrager <F.Vaandrager@cs.ru.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tortel.science.ru.nl ([131.174.16.137]:35058 "EHLO
        tortel.science.ru.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdDHUn5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 16:43:57 -0400
Received: from smtp2.science.ru.nl (smtp2.science.ru.nl [131.174.16.145])
        by tortel.science.ru.nl (8.14.4/5.32) with ESMTP id v38KT5MV007899
        for <netdev@vger.kernel.org>; Sat, 8 Apr 2017 22:29:05 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------161CC05030E03164F98EFF8D
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

My name is Paul Fiterau, I am a PhD student at Radboud University whose 
focus for the past few years has been among others to develop and apply 
inference techniques on TCP stacks in order to obtain nice models, and 
to verify them if possible using formal methods.  We contacted you on 
something similar 2 years back.

The older (3.19 kernel release) Linux TCP stack we analyze exhibits 
behavior that seems odd to me. The scenario is as follows (all packets 
have empty payloads, no window scaling, rcv/snd window size should not 
be a factor):

       TEST HARNESS (CLIENT)                        LINUX SERVER

   1.  -                                          LISTEN (server listen, then accepts)

   2.  - --> <SEQ=100><CTL=SYN>               --> SYN-RECEIVED

   3.  - <-- <SEQ=300><ACK=101><CTL=SYN,ACK>  <-- SYN-RECEIVED

   4.  - --> <SEQ=101><ACK=301><CTL=ACK>      --> ESTABLISHED
  
   5.  - <-- <SEQ=301><ACK=101><CTL=FIN,ACK>  <-- FIN WAIT-1 (server opts to close the data connection calling "close" on the connection socket)

   6.  - --> <SEQ=101><ACK=99999><CTL=FIN,ACK> --> CLOSING (client sends FIN,ACK with not yet sent acknowledgement number)

   7.  - <-- <SEQ=302><ACK=102><CTL=ACK>      <-- CLOSING (ACK is 102 instead of 101, why?)
  
... (silence from CLIENT)

   8.  - <-- <SEQ=301><ACK=102><CTL=FIN,ACK>  <-- CLOSING (retransmission, again ACK is 102)


Now, note that packet 6 while having the expected sequence number, 
acknowledges something that wasn't sent by the server. So I would expect 
the packet to maybe prompt an ACK response from the server, and then be 
ignored. Yet it is not ignored and actually leads to an increase of the 
acknowledgement number in the server's retransmission of the FIN,ACK 
packet. The explanation I found is that the FIN  in packet 6 was 
processed, despite the acknowledgement number being unacceptable. 
Further experiments indeed show that the server processes this FIN, 
transitioning to CLOSING, then on receiving an ACK for the FIN it had 
send in packet 5, the server (or better said connection) transitions 
from CLOSING to TIME_WAIT (as signaled by netstat).


I attached a capture showing the scenario, as well as an equivalent 
capture for a Windows 10 TCP server, which behaves exactly as I would 
expect by  not increasing the expected sequence number after packet 6, 
and thus not processing the FIN flag received.

I hope someone more knowledgeable can clear this up for me. Is it ok for 
the server to process the FIN bit in a packet with an unacceptable 
acknowledgement number? Could this be an inconsistency in the tested stack?


Thanks, Paul.

P.S. Our most recent publication on relating to TCP was at CAV (some big conference), article link for anyone interested
http://www.sws.cs.ru.nl/publications/papers/fvaan/FJV16/main.pdf . Now we are working on applying more advanced techniques that abstract less and capture more behavior.
P.S.2 Potentially violated RFC fragment:
    3.  If the connection is in a synchronized state (ESTABLISHED,
     FIN-WAIT-1, FIN-WAIT-2, CLOSE-WAIT, CLOSING, LAST-ACK, TIME-WAIT),
     any unacceptable segment (out of window sequence number or
     unacceptible acknowledgment number) must elicit only an empty
     acknowledgment segment containing the current send-sequence number
     and an acknowledgment indicating the next sequence number expected
     to be received, and *the connection remains in the same state*.


--------------161CC05030E03164F98EFF8D
Content-Type: application/octet-stream;
 name="linux.pcapng"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="linux.pcapng"

Cg0NCmwAAABNPCsaAQAAAP//////////AwAXAExpbnV4IDMuMTkuMC0zMi1nZW5lcmljAAQA
KQBEdW1wY2FwIDEuMTAuNiAodjEuMTAuNiBmcm9tIG1hc3Rlci0xLjEwKQAAAAAAAABsAAAA
AQAAAEQAAAABAAAA//8AAAIABABldGgxCQABAAYAAAAMABcATGludXggMy4xOS4wLTMyLWdl
bmVyaWMAAAAAAEQAAAAGAAAAWAAAAAAAAACrTAUAPsxosDYAAAA2AAAACAAnXs95CAAnBkCh
CABFAAAoAAFAAEAGSLPAqDhlwKg4Zk4spdMALI5AAAAAAFACchDJSQAAAABYAAAABgAAAFwA
AAAAAAAAq0wFACLNaLA8AAAAPAAAAAgAJwZAoQgAJ17PeQgARQAALAAAQABABkiwwKg4ZsCo
OGWl004sm+S9qgAsjkFgEnIQV+0AAAIEBbQAAFwAAAAGAAAAWAAAAAAAAACrTAUA825tsDYA
AAA2AAAACAAnXs95CAAnBkChCABFAAAoAAFAAEAGSLPAqDhlwKg4Zk4spdMALI5Bm+S9q1AQ
chBvqgAAAABYAAAABgAAAFwAAAAAAAAAq0wFALEYcrA8AAAAPAAAAAgAJwZAoQgAJ17PeQgA
RQAAKFKZQABABvYawKg4ZsCoOGWl004sm+S9qwAsjkFQEXIQb6kAAAAAAAAAAFwAAAAGAAAA
WAAAAAAAAACrTAUArDJ3sDYAAAA2AAAACAAnXs95CAAnBkChCABFAAAoAAFAAEAGSLPAqDhl
wKg4Zk4spdMALI5BnB5uQFARchC+2gAAAABYAAAABgAAAFwAAAAAAAAAq0wFAKQzd7A8AAAA
PAAAAAgAJwZAoQgAJ17PeQgARQAAKFKaQABABvYZwKg4ZsCoOGWl004sm+S9rAAsjkJQEHIQ
b6gAAAAAAAAAAFwAAAAGAAAAXAAAAAAAAACrTAUAJ/p/sDwAAAA8AAAACAAnBkChCAAnXs95
CABFAAAoUptAAEAG9hjAqDhmwKg4ZaXTTiyb5L2rACyOQlARchBvqAAAAAAAAAAAXAAAAAUA
AABsAAAAAAAAAKtMBQCFw5m7AQAcAENvdW50ZXJzIHByb3ZpZGVkIGJ5IGR1bXBjYXACAAgA
q0wFAEO69q8DAAgAq0wFADfDmbsEAAgAVwAAAAAAAAAFAAgAAAAAAAAAAAAAAAAAbAAAAA==
--------------161CC05030E03164F98EFF8D
Content-Type: application/octet-stream;
 name="win.pcapng"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="win.pcapng"

Cg0NCmwAAABNPCsaAQAAAP//////////AwAXAExpbnV4IDMuMTkuMC0zMi1nZW5lcmljAAQA
KQBEdW1wY2FwIDEuMTAuNiAodjEuMTAuNiBmcm9tIG1hc3Rlci0xLjEwKQAAAAAAAABsAAAA
AQAAAEQAAAABAAAA//8AAAIABABldGgxCQABAAYAAAAMABcATGludXggMy4xOS4wLTMyLWdl
bmVyaWMAAAAAAEQAAAAGAAAAWAAAAAAAAACrTAUA8Y5u/jYAAAA2AAAACgAnAAARCAAnBkCh
CABFAAAoAAFAAEAGSRjAqDhlwKg4AU4tzSEAY8fAAAAAAFAC/3DbRwAAAABYAAAABgAAAFwA
AAAAAAAAq0wFAMaPbv48AAAAPAAAAAgAJwZAoQoAJwAAEQgARQAALA1DQACABvvRwKg4AcCo
OGXNIU4tuhml8wBjx8FgEiAAQt4AAAIEBbQAAFwAAAAGAAAAWAAAAAAAAACrTAUAP21x/jYA
AAA2AAAACgAnAAARCAAnBkChCABFAAAoAAFAAEAGSRjAqDhlwKg4AU4tzSEAY8fBuhml9FAQ
/3B7KgAAAABYAAAABgAAAFwAAAAAAAAAq0wFAJpwdP48AAAAPAAAAAgAJwZAoQoAJwAAEQgA
RQAAKA1EQACABvvUwKg4AcCoOGXNIU4tuhml9ABjx8FQEf9weykAAAAAAAAAAFwAAAAGAAAA
WAAAAAAAAACrTAUAdbd3/jYAAAA2AAAACgAnAAARCAAnBkChCABFAAAoAAFAAEAGSRjAqDhl
wKg4AU4tzSEAY8fBuk74gFAR/3AoaAAAAABYAAAABgAAAFwAAAAAAAAAq0wFAPeeff48AAAA
PAAAAAgAJwZAoQoAJwAAEQgARQAAKA1GQACABvvSwKg4AcCoOGXNIU4tuhml9ABjx8FQEf9w
eykAAAAAAAAAAFwAAAAFAAAAbAAAAAAAAACsTAUAwtPVAQEAHABDb3VudGVycyBwcm92aWRl
ZCBieSBkdW1wY2FwAgAIAKtMBQBMOer9AwAIAKxMBQB209UBBAAIACoAAAAAAAAABQAIAAAA
AAAAAAAAAAAAAGwAAAA=
--------------161CC05030E03164F98EFF8D--
