From: Erik Slagter <erik@slagter.name>
Subject: Various strange things with ipv6 local multicast forwarding
Date: Fri, 30 Jan 2009 14:42:13 +0100
Message-ID: <498303B5.6090609@slagter.name>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms060706010901050003070507"
Cc: Pavlin Radoslavov <pavlin@ICSI.Berkeley.EDU>, todd.hayton@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eriks.xs4all.nl ([83.160.41.216]:59161 "EHLO eriks.xs4all.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752943AbZA3N4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 08:56:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms060706010901050003070507
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi All,

I am using a very simple setup: a linux server (linux 2.6.28.2, amd64) 
with 12 nics, almost each connected host has a nic uniquely to itself. 
On the server a program is running (poc-2250 to be precise) that streams 
data to multicast address ff05::4242. This data should be forwarded by 
the kernel to all interfaces that have hosts that are joined to 
ff05::4242. As it is such a simple setup, I do not want to use PIM nor a 
router application featuring PIM, I am using MLD messages only. I've 
written a very simple "MRT6_INIT" app that catches MLD messages and 
kernel upcalls, and joins interfaces on demand. This works :-)

I have had a very hard time with the kernel upcalls, but that problem 
has been solved with the recent "unnecessary skb_pull" patch I found 
here, THANKS! (Hi Todd ;-))

I now have still a few things that do not completely go like I want to 
or like I expect to. Can please someone clarify for me?

1: Next scenario:
    - Start streaming application (poc-2250)
         Now all packets go to a random interface, I cannot understand 
the logic, but most of the time it appears to be dummy0, which actually 
is a good thing. I guess it has something to do with the ff00:/8 routes 
in the "normal" routing table, from which the kernel selects one using 
some criterium. Tshark reveals the packets sent on dummy0 indeed.
    - Start "MRT6_INIT" app
    - This gets an upcall message from the kernel (which I can 
understand) for the above mc group.
    - App installs a "MFC_ADD" mcast route with the parameters from the 
upcall, with NO interfaces. My goal is to silence the streaming 
application until the stream is requested.
    - mc route gets installed OK
    - YET packets still appear on dummy0 (tshark and counters) and the 
"Wrong" (interface) counter in /proc/net/ipv6_mr_cache starts to increment.

This is not what I want and not what I expect. I expect the packets to 
be discarded if nobody is listening. I now have to run a "dummy" 
interface to drain unused packets.

    - Most of the time this more or less works, but when for a few hours 
only one interface has been joined to the mc route, a "ghost" route 
appears, which routes the packets for the multicast group directly to 
this interface, so the multicast routing system is not consulted anymore 
(counters remain steady). The route cannot be seen using "ip -6 route" 
BUT it can be deleted using "ip -6 route ff05::4242" but only when the 
multicast streaming app has been stopped. Also, the command must be 
given several times before the route is "not found".

I cannot see the logic behind this and also this is very annoying, as 
this way the mc packets always appear on this interface from this point, 
regardless whether the client on this interface has joined the group.

I already once removed all mc routes from the route table, but that 
makes the complete box fail miserably :-/

2: When a client wants to join, it sends a MLDv2 message (in my case, 
it's all linux). I catch the message and incoming interface info using 
IPV6_PKTINFO. This yields not enough information to add the client to 
the mr cache though, MFC_ADD needs a "source" interface index and 
address (and cannot use a wildcard, according to the kernel source :-(). 
At this stage I retrieve these by requesting the kernel for the route to 
multicast address (ff05::4242) which until now has been working well, 
but still I believe it's a dirty hack. There must be a more 
elegant/appropriate way to achieve this?

Somehow I get the impression the ip6 multicast routing code in the 
kernel is more targeted at multicast forwarding packets from outside the 
box than packets locally generated :-/

Thanks for your help in advance!

--------------ms060706010901050003070507
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIJUTCC
AwMwggJsoAMCAQICEGAvc086aOZ7ymp5a1XTLHcwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UE
BhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMT
I1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA4MDgxMTA4NDQzN1oX
DTA5MDgxMTA4NDQzN1owajEQMA4GA1UEBBMHU2xhZ3RlcjEVMBMGA1UEKhMMRXJpayBNYXJ0
aWpuMR0wGwYDVQQDExRFcmlrIE1hcnRpam4gU2xhZ3RlcjEgMB4GCSqGSIb3DQEJARYRZXJp
a0BzbGFndGVyLm5hbWUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDZCmPWWcxm
oBWTxF3SQ5eEvKXZykjWAU6TmmjKiECyrjRW6adVQfMCRmj8JOPQBFF2VKGD1+dY6yP/eOJE
nv58sM0JNJ9iSogxxYw9aTM4eRU7icMV3ZgXxLDmsx43Tgxmn2UkLX4qgJ7U4SexRawKebst
K+Jp93JfX9cGSx+YKvlHSLIgwEbJYoenuZb0LXsQKuswRLlsvYOz7KH06oXFDJqS2WETWHfY
VuFvcjHHUqx+ztG4gL5nl5wyEim1sk8w5GBRNiCd8SAw+SFUNjRLAcyAIqpkdfY+a2lWBL5n
eHtidBMll7zUgNIkHA9Yglp5c2ikCNckYnndFw1VCq3tAgMBAAGjLjAsMBwGA1UdEQQVMBOB
EWVyaWtAc2xhZ3Rlci5uYW1lMAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEFBQADgYEACfmg
IK9Bvs4w7cObGNNOPdt8MryEoPzr9raW48VewqJdl9o5G7iLEf9VCMxcX5VQ0M8aHNOhXgw9
urFzYSlJTBZp/dcO4Yj3VxEVe3vcIhsdyJOMD9E4MrrWJxtNihtYYa4Esm//SQ9lJ+GLgoyf
GjEGQ+QM6wKCMNwvu+RG4A8wggMDMIICbKADAgECAhBgL3NPOmjme8pqeWtV0yx3MA0GCSqG
SIb3DQEBBQUAMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAo
UHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBD
QTAeFw0wODA4MTEwODQ0MzdaFw0wOTA4MTEwODQ0MzdaMGoxEDAOBgNVBAQTB1NsYWd0ZXIx
FTATBgNVBCoTDEVyaWsgTWFydGlqbjEdMBsGA1UEAxMURXJpayBNYXJ0aWpuIFNsYWd0ZXIx
IDAeBgkqhkiG9w0BCQEWEWVyaWtAc2xhZ3Rlci5uYW1lMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEA2Qpj1lnMZqAVk8Rd0kOXhLyl2cpI1gFOk5poyohAsq40VumnVUHzAkZo
/CTj0ARRdlShg9fnWOsj/3jiRJ7+fLDNCTSfYkqIMcWMPWkzOHkVO4nDFd2YF8Sw5rMeN04M
Zp9lJC1+KoCe1OEnsUWsCnm7LSviafdyX1/XBksfmCr5R0iyIMBGyWKHp7mW9C17ECrrMES5
bL2Ds+yh9OqFxQyaktlhE1h32Fbhb3Ixx1Ksfs7RuIC+Z5ecMhIptbJPMORgUTYgnfEgMPkh
VDY0SwHMgCKqZHX2PmtpVgS+Z3h7YnQTJZe81IDSJBwPWIJaeXNopAjXJGJ53RcNVQqt7QID
AQABoy4wLDAcBgNVHREEFTATgRFlcmlrQHNsYWd0ZXIubmFtZTAMBgNVHRMBAf8EAjAAMA0G
CSqGSIb3DQEBBQUAA4GBAAn5oCCvQb7OMO3DmxjTTj3bfDK8hKD86/a2luPFXsKiXZfaORu4
ixH/VQjMXF+VUNDPGhzToV4MPbqxc2EpSUwWaf3XDuGI91cRFXt73CIbHciTjA/RODK61icb
TYobWGGuBLJv/0kPZSfhi4KMnxoxBkPkDOsCgjDcL7vkRuAPMIIDPzCCAqigAwIBAgIBDTAN
BgkqhkiG9w0BAQUFADCB0TELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTES
MBAGA1UEBxMJQ2FwZSBUb3duMRowGAYDVQQKExFUaGF3dGUgQ29uc3VsdGluZzEoMCYGA1UE
CxMfQ2VydGlmaWNhdGlvbiBTZXJ2aWNlcyBEaXZpc2lvbjEkMCIGA1UEAxMbVGhhd3RlIFBl
cnNvbmFsIEZyZWVtYWlsIENBMSswKQYJKoZIhvcNAQkBFhxwZXJzb25hbC1mcmVlbWFpbEB0
aGF3dGUuY29tMB4XDTAzMDcxNzAwMDAwMFoXDTEzMDcxNjIzNTk1OVowYjELMAkGA1UEBhMC
WkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1Ro
YXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMIGfMA0GCSqGSIb3DQEBAQUAA4GN
ADCBiQKBgQDEpjxVc1X7TrnKmVoeaMB1BHCd3+n/ox7svc31W/Iadr1/DDph8r9RzgHU5VAK
MNcCY1osiRVwjt3J8CuFWqo/cVbLrzwLB+fxH5E2JCoTzyvV84J3PQO+K/67GD4Hv0CAAmTX
p6a7n2XRxSpUhQ9IBH+nttE8YQRAHmQZcmC3+wIDAQABo4GUMIGRMBIGA1UdEwEB/wQIMAYB
Af8CAQAwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC50aGF3dGUuY29tL1RoYXd0ZVBl
cnNvbmFsRnJlZW1haWxDQS5jcmwwCwYDVR0PBAQDAgEGMCkGA1UdEQQiMCCkHjAcMRowGAYD
VQQDExFQcml2YXRlTGFiZWwyLTEzODANBgkqhkiG9w0BAQUFAAOBgQBIjNFQg+oLLswNo2as
Zw9/r6y+whehQ5aUnX9MIbj4Nh+qLZ82L8D0HFAgk3A8/a3hYWLD2ToZfoSxmRsAxRoLgnSe
JVCUYsfbJ3FXJY3dqZw5jowgT2Vfldr394fWxghOrvbqNOUQGls1TXfjViF4gtwhGTXeJLHT
HUb/XV9lTzGCA3EwggNtAgEBMHYwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBD
b25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFp
bCBJc3N1aW5nIENBAhBgL3NPOmjme8pqeWtV0yx3MAkGBSsOAwIaBQCgggHQMBgGCSqGSIb3
DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA5MDEzMDEzNDIxM1owIwYJKoZI
hvcNAQkEMRYEFF79wfgj7CEDu0ylG+wU/L62cIEsMF8GCSqGSIb3DQEJDzFSMFAwCwYJYIZI
AWUDBAECMAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0DAgIBQDAHBgUr
DgMCBzANBggqhkiG9w0DAgIBKDCBhQYJKwYBBAGCNxAEMXgwdjBiMQswCQYDVQQGEwJaQTEl
MCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3Rl
IFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0ECEGAvc086aOZ7ymp5a1XTLHcwgYcGCyqG
SIb3DQEJEAILMXigdjBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRp
bmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3Vp
bmcgQ0ECEGAvc086aOZ7ymp5a1XTLHcwDQYJKoZIhvcNAQEBBQAEggEAe36pW4/ne63/sXjm
C+587mH15rOz69sTZAYGWnhYl+fc+mKvNyynnqSnMuorBXnHKlls0lQWD1Os3cPBrROaFJHb
+iAHq81qjJ5tJXtqs7O6gZcMRMxRAgJLqyuj6oNbQib4Fngtb9rU+KnZoSNRB8i81NO7Sy/L
84JXOvhIGU5Vq00mRyw95UZPVkOD2MdT5WPZRRfOf1smYraE4G2UB1hSZluS8P6+5La+qdQO
KIIqLhg4+9w/hu6lPDSindSAryMjAdEugSEHxrqYwAQJgFWlX+Ee8E5vICVEHX3NHkZ0fdk0
TJvjLxO5Hli+tjC4FAsx2dlPrjlI9hT32SZCfgAAAAAAAA==
--------------ms060706010901050003070507--
