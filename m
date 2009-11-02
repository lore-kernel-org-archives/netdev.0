From: Sven Anders <anders@anduras.de>
Subject: Bugfix for iproute2
Date: Tue, 03 Nov 2009 00:45:24 +0100
Message-ID: <4AEF6F14.7080802@anduras.de>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms040009000802000402080100"
Cc: shemminger@vyatta.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:45060 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756940AbZKCATO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 19:19:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms040009000802000402080100
Content-Type: multipart/mixed;
 boundary="------------060108080302090001010405"

This is a multi-part message in MIME format.
--------------060108080302090001010405
Content-Type: text/plain; charset=Big5
Content-Transfer-Encoding: 7bit

Hello!

I already send this mail to Stephen Hemminger, but I'm not sure if it reached him.
Moreover I tried to join the LARTC mailing list (http://mailman.ds9a.nl/mailman/listinfo/lartc)
but it did not work. Is this mailing list dead?
Therefore I sent this mail again over this mailing list...


I experienced an error, if I try to perform a

  ip route flush proto 4

with many routes in a complex environment, it
gave me the following error:

  Failed to send flush request: Success
  Flush terminated

I'm using version 2.6.29.
I check GIT, but there was only the "MSG_PEEK" fix.

I tracked it down to the rtnl_send_check() function
in lib/libnetlink.c.

In this function there is the following for loop:

        for (h = (struct nlmsghdr *)resp; NLMSG_OK(h, status);
             h = NLMSG_NEXT(h, status)) {
                if (h->nlmsg_type == NLMSG_ERROR) {
                        struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
                        if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr)))
                                fprintf(stderr, "ERROR truncated\n");
                        else
                                errno = -err->error;
		}
                return -1;
        }

I think the "return -1;" should be inside the if statement.

I attached a patch for this. The first part of the patch is taken from
one of the late git commits.

Please note me, if the fix is wrong...

Regards
 Sven Anders

-- 
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign
                                                 /\ Support plain text e-mail
 ANDURAS service solutions AG
 Innstrasse 71 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 50-55

Those who would give up essential Liberty, to purchase a little
temporary Safety, deserve neither Liberty nor Safety.
  - Benjamin Franklin


--------------060108080302090001010405
Content-Type: text/x-patch;
 name="iproute-2.6.29-flush.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iproute-2.6.29-flush.patch"

--- iproute2-2.6.29/lib/libnetlink.c.orig	2009-09-23 14:47:03.000000000 +0200
+++ iproute2-2.6.29/lib/libnetlink.c	2009-09-23 14:48:09.000000000 +0200
@@ -122,7 +122,7 @@ int rtnl_send_check(struct rtnl_handle *
 		return status;
 
 	/* Check for errors */
-	status = recv(rth->fd, resp, sizeof(resp), MSG_DONTWAIT);
+	status = recv(rth->fd, resp, sizeof(resp), MSG_DONTWAIT|MSG_PEEK);
 	if (status < 0) {
 		if (errno == EAGAIN)
 			return 0;
@@ -137,8 +137,8 @@ int rtnl_send_check(struct rtnl_handle *
 				fprintf(stderr, "ERROR truncated\n");
 			else 
 				errno = -err->error;
-		}
 		return -1;
+		}
 	}
 
 	return 0;


--------------060108080302090001010405
Content-Type: application/pgp-signature;
 name="signature.asc"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="signature.asc"

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KVmVyc2lvbjogR251UEcgdjEuNC45IChH
TlUvTGludXgpCkNvbW1lbnQ6IFVzaW5nIEdudVBHIHdpdGggTW96aWxsYSAtIGh0dHA6Ly9l
bmlnbWFpbC5tb3pkZXYub3JnCgppRVlFQVJFQ0FBWUZBa3E2SHc4QUNna1E1bEtaN0ZlZzRF
ZEs5QUNhQXlhTDVBOEFIYmM4RHRRMzcvTVJOUkIwClAvQUFuaXpONUdYb1k3VVV1cldsOFNE
Zy9wL2dOM09VCj0yT0lhCi0tLS0tRU5EIFBHUCBTSUdOQVRVUkUtLS0tLQoK
--------------060108080302090001010405
Content-Type: text/x-vcard; charset=utf-8;
 name="anders.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="anders.vcf"

YmVnaW46dmNhcmQNCmZuOlN2ZW4gQW5kZXJzDQpuOkFuZGVycztTdmVuDQpvcmc6QU5EVVJB
UyBBRztSZXNlYXJjaCBhbmQgRGV2ZWxvcG1lbnQNCmFkcjtxdW90ZWQtcHJpbnRhYmxlOjs7
SW5uc3RyYT1DMz05RmUgNzE7UGFzc2F1O0JhdmFyaWE7OTQwMzY7R2VybWFueQ0KZW1haWw7
aW50ZXJuZXQ6YW5kZXJzQGFuZHVyYXMuZGUNCnRpdGxlOkRpcGwuIEluZi4NCnRlbDt3b3Jr
OisrNDkgKDApODUxIC8gNDkwIDUwIC0wDQp0ZWw7ZmF4OisrNDkgKDApODUxIC8gNTkwIDUw
IC0gNTUNCngtbW96aWxsYS1odG1sOkZBTFNFDQp1cmw6aHR0cDovL3d3dy5hbmR1cmFzLmRl
DQp2ZXJzaW9uOjIuMQ0KZW5kOnZjYXJkDQoNCg==
--------------060108080302090001010405--

--------------ms040009000802000402080100
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIOsDCC
B1QwggU8oAMCAQICAxAABTANBgkqhkiG9w0BAQUFADCBqjELMAkGA1UEBhMCREUxCzAJBgNV
BAgTAkJZMQ8wDQYDVQQHEwZQYXNzYXUxEzARBgNVBAoTCkFORFVSQVMgQUcxHjAcBgNVBAsT
FUNlcnRpZmljYXRlIEF1dGhvcml0eTEpMCcGA1UEAxMgQU5EVVJBUyBBRyBDZXJ0aWZpY2F0
ZSBBdXRob3JpdHkxHTAbBgkqhkiG9w0BCQEWDnBraUBhbmR1cmFzLmRlMB4XDTA5MTAyMDIw
MzQ1N1oXDTE0MTAyMDIwMzQ1N1owgbAxCzAJBgNVBAYTAkRFMQswCQYDVQQIEwJCWTEPMA0G
A1UEBxMGUGFzc2F1MRMwEQYDVQQKEwpBTkRVUkFTIEFHMSkwJwYDVQQKEyBmOTIyMjlhOWM5
MjBiOGVkZGEwYzRlYzg4MGQ4ZTgzYjELMAkGA1UECxMCR0wxFDASBgNVBAMTC3N2ZW4uYW5k
ZXJzMSAwHgYJKoZIhvcNAQkBFhFhbmRlcnNAYW5kdXJhcy5kZTCCASIwDQYJKoZIhvcNAQEB
BQADggEPADCCAQoCggEBALxbO8bh1hRSEsTu7n/7sPpS7fHqLeQWzwg1mengwU8V1xK3nfB5
gA/LyZDo96CDnhlnizlaSXRHCjVOVGO7IiM/GWhRFhSXBz1uqv0FHffkC1xI0T1C9ySSDp4R
RgKry3PiR79wS9E2fzKjqctNZIld3blaGBHmElRSEjHuxOiyR/k0I1YndkLrJA/n4UsLzoEF
qGNJ49EDRucUEL1bBCjT8ZiCiPrQiBSfk2K5BPtqg68I+BQMjIAVmhpvxv5UQcrKWKFoeWyF
JqgJb4+gioDlDuTYUxDjurdU6+dI+I011vS/rj5qe81DcXNiQA55NqTgDQrsJCyj+H0qMZW2
lk0CAwEAAaOCAnkwggJ1MAwGA1UdEwEB/wQCMAAwDgYDVR0PAQH/BAQDAgP4MCoGA1UdJQQj
MCEGCCsGAQUFBwMEBggrBgEFBQcDAgYLKwYBBAGB6y0DAQEwFAYJYIZIAYb4QgEBAQH/BAQD
AgWgMB0GA1UdDgQWBBT1nf148Ot7Zwor+h/kFKOzgPoJPzCB3wYDVR0jBIHXMIHUgBQ34zit
047U9ZuPSA8TE9kjVMkm96GBsKSBrTCBqjELMAkGA1UEBhMCREUxCzAJBgNVBAgTAkJZMQ8w
DQYDVQQHEwZQYXNzYXUxEzARBgNVBAoTCkFORFVSQVMgQUcxHjAcBgNVBAsTFUNlcnRpZmlj
YXRlIEF1dGhvcml0eTEpMCcGA1UEAxMgQU5EVVJBUyBBRyBDZXJ0aWZpY2F0ZSBBdXRob3Jp
dHkxHTAbBgkqhkiG9w0BCQEWDnBraUBhbmR1cmFzLmRlggkAhNxpBFvYvqIwGQYDVR0SBBIw
EIEOcGtpQGFuZHVyYXMuZGUwYAYDVR0fBFkwVzApoCegJYYjaHR0cDovL2NhLmFuZHVyYXMu
ZGUvYW5kdXJhcy1jYS5jcmwwKqAooCaGJGh0dHA6Ly9jcmwuYW5kdXJhcy5kZS9hbmR1cmFz
LWNhLmNybDAuBglghkgBhvhCAQ0EIRYfQU5EVVJBUyBBRyBQZXJzb25hbCBDZXJ0aWZpY2F0
ZTBlBggrBgEFBQcBAQRZMFcwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLmFuZHVyYXMuZGUv
MDAGCCsGAQUFBzAChiRodHRwOi8vY2EuYW5kdXJhcy5kZS9hbmR1cmFzLWNhLmh0bWwwDQYJ
KoZIhvcNAQEFBQADggIBAD7x+V+hQ00k19ISJgTDzupxFpAnOugXe2sgM9zmdx+RlsAJ56mB
nvdhoTtlwi2wCUV1jW848w024TJ+xW5kOrU5RzpWc+8lrOhakcs4VYgaYez+fSXOk/t1gAxV
haFglg5mfdj5XZvKs8NnvlkKZioWWbKVW6S404HGNn5pOwxRnT+1SaSpSWxWbng0XC6BZuP4
FkxnKD9yCWcKDbfkIYk3CQFAlVMB6jZNffiScf9SVHkwytnw+Op0LwvEaK9oSJ+9KxPKYbkG
V4DP3bDujeI448gUZExT/FH501eaWr0U3P6I88Omru6UwVZnIx+cJgUmNGr0RoyPMuD5KAX6
1cvDukeJVLhT3uUChsl3huWQkUVH6kvPqNyG+PM1LnhGk0LGGQvk5NMMHDFl9Su+9SRIh8BA
xb8dbIUEorXKgYoxNWGdv/0qpcik7pUOygqSdYOleIqlUVUG53KtwVhrOvZEpu3kSldTm5m2
z16VD4AIediBB5AxpyWVF3OXyGLrsKWofydZrrMdu+l0GNKPC2NVFGlXt3U49b+nvsW4TSBP
IbIkTmbQwbbj0jXVrBfzx95zHsaq7152Y+857Fm9NSSws1nEBvMBSVmCsRtM00tqZedVZzZG
VFKHByO2+xsG0QSksVA0VGIDczgpmjJBVm2UkO66/ZBwQ/mm6u3wMx4OMIIHVDCCBTygAwIB
AgIDEAAFMA0GCSqGSIb3DQEBBQUAMIGqMQswCQYDVQQGEwJERTELMAkGA1UECBMCQlkxDzAN
BgNVBAcTBlBhc3NhdTETMBEGA1UEChMKQU5EVVJBUyBBRzEeMBwGA1UECxMVQ2VydGlmaWNh
dGUgQXV0aG9yaXR5MSkwJwYDVQQDEyBBTkRVUkFTIEFHIENlcnRpZmljYXRlIEF1dGhvcml0
eTEdMBsGCSqGSIb3DQEJARYOcGtpQGFuZHVyYXMuZGUwHhcNMDkxMDIwMjAzNDU3WhcNMTQx
MDIwMjAzNDU3WjCBsDELMAkGA1UEBhMCREUxCzAJBgNVBAgTAkJZMQ8wDQYDVQQHEwZQYXNz
YXUxEzARBgNVBAoTCkFORFVSQVMgQUcxKTAnBgNVBAoTIGY5MjIyOWE5YzkyMGI4ZWRkYTBj
NGVjODgwZDhlODNiMQswCQYDVQQLEwJHTDEUMBIGA1UEAxMLc3Zlbi5hbmRlcnMxIDAeBgkq
hkiG9w0BCQEWEWFuZGVyc0BhbmR1cmFzLmRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAvFs7xuHWFFISxO7uf/uw+lLt8eot5BbPCDWZ6eDBTxXXEred8HmAD8vJkOj3oIOe
GWeLOVpJdEcKNU5UY7siIz8ZaFEWFJcHPW6q/QUd9+QLXEjRPUL3JJIOnhFGAqvLc+JHv3BL
0TZ/MqOpy01kiV3duVoYEeYSVFISMe7E6LJH+TQjVid2QuskD+fhSwvOgQWoY0nj0QNG5xQQ
vVsEKNPxmIKI+tCIFJ+TYrkE+2qDrwj4FAyMgBWaGm/G/lRByspYoWh5bIUmqAlvj6CKgOUO
5NhTEOO6t1Tr50j4jTXW9L+uPmp7zUNxc2JADnk2pOANCuwkLKP4fSoxlbaWTQIDAQABo4IC
eTCCAnUwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCA/gwKgYDVR0lBCMwIQYIKwYBBQUH
AwQGCCsGAQUFBwMCBgsrBgEEAYHrLQMBATAUBglghkgBhvhCAQEBAf8EBAMCBaAwHQYDVR0O
BBYEFPWd/Xjw63tnCiv6H+QUo7OA+gk/MIHfBgNVHSMEgdcwgdSAFDfjOK3TjtT1m49IDxMT
2SNUySb3oYGwpIGtMIGqMQswCQYDVQQGEwJERTELMAkGA1UECBMCQlkxDzANBgNVBAcTBlBh
c3NhdTETMBEGA1UEChMKQU5EVVJBUyBBRzEeMBwGA1UECxMVQ2VydGlmaWNhdGUgQXV0aG9y
aXR5MSkwJwYDVQQDEyBBTkRVUkFTIEFHIENlcnRpZmljYXRlIEF1dGhvcml0eTEdMBsGCSqG
SIb3DQEJARYOcGtpQGFuZHVyYXMuZGWCCQCE3GkEW9i+ojAZBgNVHRIEEjAQgQ5wa2lAYW5k
dXJhcy5kZTBgBgNVHR8EWTBXMCmgJ6AlhiNodHRwOi8vY2EuYW5kdXJhcy5kZS9hbmR1cmFz
LWNhLmNybDAqoCigJoYkaHR0cDovL2NybC5hbmR1cmFzLmRlL2FuZHVyYXMtY2EuY3JsMC4G
CWCGSAGG+EIBDQQhFh9BTkRVUkFTIEFHIFBlcnNvbmFsIENlcnRpZmljYXRlMGUGCCsGAQUF
BwEBBFkwVzAjBggrBgEFBQcwAYYXaHR0cDovL29jc3AuYW5kdXJhcy5kZS8wMAYIKwYBBQUH
MAKGJGh0dHA6Ly9jYS5hbmR1cmFzLmRlL2FuZHVyYXMtY2EuaHRtbDANBgkqhkiG9w0BAQUF
AAOCAgEAPvH5X6FDTSTX0hImBMPO6nEWkCc66Bd7ayAz3OZ3H5GWwAnnqYGe92GhO2XCLbAJ
RXWNbzjzDTbhMn7FbmQ6tTlHOlZz7yWs6FqRyzhViBph7P59Jc6T+3WADFWFoWCWDmZ92Pld
m8qzw2e+WQpmKhZZspVbpLjTgcY2fmk7DFGdP7VJpKlJbFZueDRcLoFm4/gWTGcoP3IJZwoN
t+QhiTcJAUCVUwHqNk19+JJx/1JUeTDK2fD46nQvC8Ror2hIn70rE8phuQZXgM/dsO6N4jjj
yBRkTFP8UfnTV5pavRTc/ojzw6au7pTBVmcjH5wmBSY0avRGjI8y4PkoBfrVy8O6R4lUuFPe
5QKGyXeG5ZCRRUfqS8+o3Ib48zUueEaTQsYZC+Tk0wwcMWX1K771JEiHwEDFvx1shQSitcqB
ijE1YZ2//SqlyKTulQ7KCpJ1g6V4iqVRVQbncq3BWGs69kSm7eRKV1ObmbbPXpUPgAh52IEH
kDGnJZUXc5fIYuuwpah/J1musx276XQY0o8LY1UUaVe3dTj1v6e+xbhNIE8hsiROZtDBtuPS
NdWsF/PH3nMexqrvXnZj7znsWb01JLCzWcQG8wFJWYKxG0zTS2pl51VnNkZUUocHI7b7GwbR
BKSxUDRUYgNzOCmaMkFWbZSQ7rr9kHBD+abq7fAzHg4xggQqMIIEJgIBATCBsjCBqjELMAkG
A1UEBhMCREUxCzAJBgNVBAgTAkJZMQ8wDQYDVQQHEwZQYXNzYXUxEzARBgNVBAoTCkFORFVS
QVMgQUcxHjAcBgNVBAsTFUNlcnRpZmljYXRlIEF1dGhvcml0eTEpMCcGA1UEAxMgQU5EVVJB
UyBBRyBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxHTAbBgkqhkiG9w0BCQEWDnBraUBhbmR1cmFz
LmRlAgMQAAUwCQYFKw4DAhoFAKCCAkwwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkq
hkiG9w0BCQUxDxcNMDkxMTAyMjM0NTI0WjAjBgkqhkiG9w0BCQQxFgQU0RVwwypnIYjPRbhA
iDO75R+GJVswXwYJKoZIhvcNAQkPMVIwUDALBglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYI
KoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIHD
BgkrBgEEAYI3EAQxgbUwgbIwgaoxCzAJBgNVBAYTAkRFMQswCQYDVQQIEwJCWTEPMA0GA1UE
BxMGUGFzc2F1MRMwEQYDVQQKEwpBTkRVUkFTIEFHMR4wHAYDVQQLExVDZXJ0aWZpY2F0ZSBB
dXRob3JpdHkxKTAnBgNVBAMTIEFORFVSQVMgQUcgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MR0w
GwYJKoZIhvcNAQkBFg5wa2lAYW5kdXJhcy5kZQIDEAAFMIHFBgsqhkiG9w0BCRACCzGBtaCB
sjCBqjELMAkGA1UEBhMCREUxCzAJBgNVBAgTAkJZMQ8wDQYDVQQHEwZQYXNzYXUxEzARBgNV
BAoTCkFORFVSQVMgQUcxHjAcBgNVBAsTFUNlcnRpZmljYXRlIEF1dGhvcml0eTEpMCcGA1UE
AxMgQU5EVVJBUyBBRyBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxHTAbBgkqhkiG9w0BCQEWDnBr
aUBhbmR1cmFzLmRlAgMQAAUwDQYJKoZIhvcNAQEBBQAEggEATJYMmk0jkWqBRa5KeBn+YuKq
UDm4IxiSXDC6UYQf6fE+WAzsRsDyLEOb5EQzOjEiUDBka7w58m/f2UbetPoS+jsrHYGRduV9
+QAt1Yx8VEKWL+mQ+jt+7fnNG6WCzbE9mO9izXNinyF4UzeDJe+rbN9KV4myN3U8nSZSmTLn
DqqMQ8iXW4GyDFPFRIuzfDT1UlrHx46Ytd3jrgXx5EP1cM7GilgFKm/wEc5kUMQOuM3pMvli
edox7Qka3ZcPXQm7/Qt45bXvwwEBOTV2JPbdkgS7+zqjWdpLkQqUo10fRjyQjo1bGMjV5eHF
vMwbeiGqusOgZAiAp9XxfCf1qT5xRQAAAAAAAA==
--------------ms040009000802000402080100--
