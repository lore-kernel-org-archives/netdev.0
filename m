From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Gaah: selinux_socket_unix_stream_connect oops
Date: Wed, 5 Jan 2011 08:27:01 -0800
Message-ID: <AANLkTikPvJLEZetB-CbVSO0VuYLnAQz5y8D_F0HGML=5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000325575ae61248a204991bdc0c
To: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35214 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751920Ab1AEQ1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 11:27:24 -0500
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p05GRM8r026270
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 5 Jan 2011 08:27:22 -0800
Received: by iwn9 with SMTP id 9so15383217iwn.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 08:27:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--000325575ae61248a204991bdc0c
Content-Type: text/plain; charset=ISO-8859-1

This was actually a regression entry, but only ever reported once by
Jeremy, I think. So it was basically ignored as not being very common
and there not being any hints about what causes it.

But after doing the 2.6.37 release, and intending to put it on all the
machines I have access to, guess what I find on the kids computer?
Right.

It must be a reasonably rare race condition, because that computer had
been up for three weeks or so (since middle of December), but
yesterday evening it crashed due to that thing.

The code disassembly is

  13:	55                   	push   %ebp
  14:	89 e5                	mov    %esp,%ebp
  16:	57                   	push   %edi
  17:	8d 7d 90             	lea    -0x70(%ebp),%edi
  1a:	56                   	push   %esi
  1b:	53                   	push   %ebx
  1c:	83 ec 6c             	sub    $0x6c,%esp
  1f:	8b 40 14             	mov    0x14(%eax),%eax
  22:	8b 52 14             	mov    0x14(%edx),%edx
  25:	8b 98 58 01 00 00    	mov    0x158(%eax),%ebx
  2b:*	8b 82 58 01 00 00    	mov    0x158(%edx),%eax     <-- trapping
instruction
  31:	89 45 8c             	mov    %eax,-0x74(%ebp)
  34:	31 c0                	xor    %eax,%eax
  36:	8b b1 58 01 00 00    	mov    0x158(%ecx),%esi
  3c:	89 7d 88             	mov    %edi,-0x78(%ebp)

which means that it's "other->sk" that is NULL, which I think matches
Jeremy's case exactly.

The logs have a hint: this seems to have coincided with the
console-kit-daemon giving a warning like:

  WARNING: Couldn't read /proc/13585/environ: Failed to open file
'/proc/13585/environ': No such file or directory

and then NetworkManager having a bunch of authentication warnings that
end up about being

  Could not get UID of name ':1.3871': no such name

(full text in the attachment).

So I wonder if there is some subtle race that happens when one end of
a unix domain socket attaches just as another end disconnects?
Especially as "security_unix_stream_connect()" is called before the
whole connect sequence is really final. It's generally
"unix_release()" that sets 'sock->sk' to NULL.

Btw, why do we pass in "sock" and "other->sk_socket" ("struct
socket"), when it appears that what the security code really wants to
get "struct sock" (which would be "sk" and "other" in the caller)? The
calling convention seems to result in (a) this NULL pointer thing and
(b) all these extra dereferences.

Comments? Ideas?

                              Linus

--000325575ae61248a204991bdc0c
Content-Type: text/plain; charset=US-ASCII; name="kids.txt"
Content-Disposition: attachment; filename="kids.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gikf9ygx0

SGFwcGVuZWQgd2l0aAoKIExpbnV4IHZlcnNpb24gMi42LjM3LXJjNS0wMDMzMy1nZGFlZmMzZAoK
YWZ0ZXIgcGVyaGFwcyB0aHJlZSB3ZWVrcyBvZiB1cHRpbWUuICBUaGF0IGtlcm5lbCBpc24ndCBp
biBnaXQsIGl0IGhhcwphbiBleHRyYSBwYXRjaCAodG8gZm9yY2UtZW5hYmxlIEFIQ0kgb24gdGhl
IG1hYyBtaW5pKSwgc28gaXQncyByZWFsbHkKdjIuNi4zNy1yYzUtMzMyLWcwZmNkY2ZiYmM5OGYg
aW4gYmFzZWxpbmUuCgotLS0KSmFuICA0IDE3OjAyOjUwIGtpZHMgY29uc29sZS1raXQtZGFlbW9u
WzI4ODRdOiBXQVJOSU5HOiBDb3VsZG4ndCByZWFkIC9wcm9jLzEzNTg1L2Vudmlyb246IEZhaWxl
ZCB0byBvcGVuIGZpbGUgJy9wcm9jLzEzNTg1L2Vudmlyb24nOiBObyBzdWNoIGZpbGUgb3IgZGly
ZWN0b3J5CkphbiAgNCAxNzowMjo1MCBraWRzIE5ldHdvcmtNYW5hZ2VyWzI0MzhdOiA8d2Fybj4g
ZXJyb3IgcmVxdWVzdGluZyBhdXRoIGZvciBvcmcuZnJlZWRlc2t0b3AuTmV0d29ya01hbmFnZXIu
bmV0d29yay1jb250cm9sOiAoNikgUmVtb3RlIEV4Y2VwdGlvbiBpbnZva2luZyBvcmcuZnJlZWRl
c2t0b3AuUG9saWN5S2l0MS5BdXRob3JpdHkuQ2hlY2tBdXRob3JpemF0aW9uKCkgb24gL29yZy9m
cmVlZGUuLi4KCQkJCS4uLk5hbWVIYXNOb093bmVyOiBDb3VsZCBub3QgZ2V0IFVJRCBvZiBuYW1l
ICc6MS4zODcxJzogbm8gc3VjaCBuYW1lCkphbiAgNCAxNzowMjo1MCBraWRzIE5ldHdvcmtNYW5h
Z2VyWzI0MzhdOiA8d2Fybj4gVXNlciBjb25uZWN0aW9ucyB1bmF2YWlsYWJsZTogKDYpIFJlbW90
ZSBFeGNlcHRpb24gaW52b2tpbmcgb3JnLmZyZWVkZXNrdG9wLlBvbGljeUtpdDEuQXV0aG9yaXR5
LkNoZWNrQXV0aG9yaXphdGlvbigpIC4uLgpKYW4gIDQgMTc6MDI6NTAga2lkcyBOZXR3b3JrTWFu
YWdlclsyNDM4XTogPHdhcm4+IGVycm9yIHJlcXVlc3RpbmcgYXV0aCBmb3Igb3JnLmZyZWVkZXNr
dG9wLk5ldHdvcmtNYW5hZ2VyLmVuYWJsZS1kaXNhYmxlLW5ldHdvcms6ICg2KSBSZW1vdGUgRXhj
ZXB0aW9uIGludm9raW5nIG9yZy5mcmUuLi4KSmFuICA0IDE3OjAyOjUwIGtpZHMgTmV0d29ya01h
bmFnZXJbMjQzOF06IDx3YXJuPiBlcnJvciByZXF1ZXN0aW5nIGF1dGggZm9yIG9yZy5mcmVlZGVz
a3RvcC5OZXR3b3JrTWFuYWdlci5zbGVlcC13YWtlOiAoNikgUmVtb3RlIEV4Y2VwdGlvbiBpbnZv
a2luZyBvcmcuZnJlZWRlc2t0b3AuUG9sLi4uCkphbiAgNCAxNzowMjo1MCBraWRzIE5ldHdvcmtN
YW5hZ2VyWzI0MzhdOiA8d2Fybj4gZXJyb3IgcmVxdWVzdGluZyBhdXRoIGZvciBvcmcuZnJlZWRl
c2t0b3AuTmV0d29ya01hbmFnZXIuZW5hYmxlLWRpc2FibGUtd2lmaTogKDYpIFJlbW90ZSBFeGNl
cHRpb24gaW52b2tpbmcgb3JnLmZyZWVkZS4uLgpKYW4gIDQgMTc6MDI6NTAga2lkcyBOZXR3b3Jr
TWFuYWdlclsyNDM4XTogPHdhcm4+IGVycm9yIHJlcXVlc3RpbmcgYXV0aCBmb3Igb3JnLmZyZWVk
ZXNrdG9wLk5ldHdvcmtNYW5hZ2VyLmVuYWJsZS1kaXNhYmxlLXd3YW46ICg2KSBSZW1vdGUgRXhj
ZXB0aW9uIGludm9raW5nIG9yZy5mcmVlZGUuLi4KSmFuICA0IDE3OjAyOjUwIGtpZHMgTmV0d29y
a01hbmFnZXJbMjQzOF06IDx3YXJuPiBlcnJvciByZXF1ZXN0aW5nIGF1dGggZm9yIG9yZy5mcmVl
ZGVza3RvcC5OZXR3b3JrTWFuYWdlci51c2UtdXNlci1jb25uZWN0aW9uczogKDYpIFJlbW90ZSBF
eGNlcHRpb24gaW52b2tpbmcgb3JnLmZyZWVkLi4uCkphbiAgNCAxNzowMjo1MCBraWRzIE5ldHdv
cmtNYW5hZ2VyWzI0MzhdOiA8d2Fybj4gZXJyb3IgcmVxdWVzdGluZyBhdXRoIGZvciBvcmcuZnJl
ZWRlc2t0b3AuTmV0d29ya01hbmFnZXIubmV0d29yay1jb250cm9sOiAoNikgUmVtb3RlIEV4Y2Vw
dGlvbiBpbnZva2luZyBvcmcuZnJlZWRlc2t0by4uLgpKYW4gIDQgMTc6MDI6NTAga2lkcyBib25v
Ym8tYWN0aXZhdGlvbi1zZXJ2ZXIgKGNlbGVzdGUtMTUwNzUpOiBjb3VsZCBub3QgYXNzb2NpYXRl
IHdpdGggZGVza3RvcCBzZXNzaW9uOiBGYWlsZWQgdG8gY29ubmVjdCB0byBzb2NrZXQgL3RtcC9k
YnVzLThBWGp6dXV3Mkk6IENvbm5lY3Rpb24gcmUuLi4KCQkJCS4uLk5hbWVIYXNOb093bmVyOiBD
b3VsZCBub3QgZ2V0IFVJRCBvZiBuYW1lICc6MS4zODcxJzogbm8gc3VjaCBuYW1lCkphbiAgNCAx
NzowMjo1MCBraWRzIGtlcm5lbDogWzE3NTU0NjUuOTU1NDgwXSBCVUc6IHVuYWJsZSB0byBoYW5k
bGUga2VybmVsIE5VTEwgcG9pbnRlciBkZXJlZmVyZW5jZSBhdCAwMDAwMDE1OApKYW4gIDQgMTc6
MDI6NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIyNl0gSVA6IFs8YzExMTI5N2U+XSBzZWxp
bnV4X3NvY2tldF91bml4X3N0cmVhbV9jb25uZWN0KzB4MTgvMHg4NApKYW4gIDQgMTc6MDI6NTAg
a2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIyNl0gKnBkZSA9IDAwMDAwMDAwCkphbiAgNCAxNzow
Mjo1MCBraWRzIGtlcm5lbDogWzE3NTU0NjUuOTU2MjI2XSBPb3BzOiAwMDAwIFsjMV0gU01QCkph
biAgNCAxNzowMjo1MCBraWRzIGtlcm5lbDogWzE3NTU0NjUuOTU2MjI2XSBsYXN0IHN5c2ZzIGZp
bGU6IC9zeXMvZGV2aWNlcy92aXJ0dWFsL3NvdW5kL3RpbWVyL3VldmVudApKYW4gIDQgMTc6MDI6
NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIyNl0gTW9kdWxlcyBsaW5rZWQgaW46IFtsYXN0
IHVubG9hZGVkOiBzY3NpX3dhaXRfc2Nhbl0KSmFuICA0IDE3OjAyOjUwIGtpZHMga2VybmVsOiBb
MTc1NTQ2NS45NTYyMjZdCkphbiAgNCAxNzowMjo1MCBraWRzIGtlcm5lbDogWzE3NTU0NjUuOTU2
MjI2XSBQaWQ6IDE1MDc1LCBjb21tOiBib25vYm8tYWN0aXZhdGkgTm90IHRhaW50ZWQgMi42LjM3
LXJjNS0wMDMzMy1nZGFlZmMzZCAjMTMgTWFjLUY0MjA4RUM4L01hY21pbmkxLDEKSmFuICA0IDE3
OjAyOjUwIGtpZHMga2VybmVsOiBbMTc1NTQ2NS45NTYyMjZdIEVJUDogMDA2MDpbPGMxMTEyOTdl
Pl0gRUZMQUdTOiAwMDIxMDI5NiBDUFU6IDEKSmFuICA0IDE3OjAyOjUwIGtpZHMga2VybmVsOiBb
MTc1NTQ2NS45NTYyMjZdIEVJUCBpcyBhdCBzZWxpbnV4X3NvY2tldF91bml4X3N0cmVhbV9jb25u
ZWN0KzB4MTgvMHg4NApKYW4gIDQgMTc6MDI6NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIy
Nl0gRUFYOiBlZTQ4YjIwMCBFQlg6IGYxZjk4M2MwIEVDWDogZWU0OGJlMDAgRURYOiAwMDAwMDAw
MApKYW4gIDQgMTc6MDI6NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIyNl0gRVNJOiBlZTQ4
YjIwMCBFREk6IGY1OWM1ZTFjIEVCUDogZjU5YzVlOGMgRVNQOiBmNTljNWUxNApKYW4gIDQgMTc6
MDI6NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIyNl0gIERTOiAwMDdiIEVTOiAwMDdiIEZT
OiAwMGQ4IEdTOiAwMDMzIFNTOiAwMDY4CkphbiAgNCAxNzowMjo1MCBraWRzIGtlcm5lbDogWzE3
NTU0NjUuOTU2MjI2XSBQcm9jZXNzIGJvbm9iby1hY3RpdmF0aSAocGlkOiAxNTA3NSwgdGk9ZjU5
YzQwMDAgdGFzaz1lZTQ1ZWI1MCB0YXNrLnRpPWY1OWM0MDAwKQpKYW4gIDQgMTc6MDI6NTAga2lk
cyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIyNl0gU3RhY2s6CkphbiAgNCAxNzowMjo1MCBraWRzIGtl
cm5lbDogWzE3NTU0NjUuOTU2MjI2XSAgMDAwMDAwMDAgMDAwMDAwMDAgMDAwMDAwMDAgMDAwMDAw
MDAgMDAwMDAwMDAgMDAyMDAwNDYgMDAyMDAwNDYgMDAwMDAwNTkKSmFuICA0IDE3OjAyOjUwIGtp
ZHMga2VybmVsOiBbMTc1NTQ2NS45NTYyMjZdICAwMDAwMDAxMyAwMDAwMDAwMCBmNTljNWU0NCBj
MTAzMDcwZSBmNTljNWU1YyBjMTAwM2NjNSBmNTljNWU2NCBlZTQzMmEwMApKYW4gIDQgMTc6MDI6
NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIyNl0gIGVlNDhiMjAwIGVlNDhiZTAwIGY1OWM1
ZWQ0IGMxMDAyY2U5IGVlNDMyYTAwIGY1OWM1ZWMwIGUxYjAyOTAwIGVlNDhiMjAwCkphbiAgNCAx
NzowMjo1MCBraWRzIGtlcm5lbDogWzE3NTU0NjUuOTU2MjI2XSBDYWxsIFRyYWNlOgpKYW4gIDQg
MTc6MDI6NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIyNl0gIFs8YzEwMzA3MGU+XSA/IGly
cV9leGl0KzB4MzkvMHg1ZApKYW4gIDQgMTc6MDI6NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1
NjIyNl0gIFs8YzEwMDNjYzU+XSA/IGRvX0lSUSsweDgzLzB4OTcKSmFuICA0IDE3OjAyOjUwIGtp
ZHMga2VybmVsOiBbMTc1NTQ2NS45NTYyMjZdICBbPGMxMDAyY2U5Pl0gPyBjb21tb25faW50ZXJy
dXB0KzB4MjkvMHgzMApKYW4gIDQgMTc6MDI6NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIy
Nl0gIFs8YzExMTA3MmM+XSA/IHNlY3VyaXR5X3VuaXhfc3RyZWFtX2Nvbm5lY3QrMHgxMC8weDEz
CkphbiAgNCAxNzowMjo1MCBraWRzIGtlcm5lbDogWzE3NTU0NjUuOTU2MjI2XSAgWzxjMTM5MDAy
OT5dID8gdW5peF9zdHJlYW1fY29ubmVjdCsweDFlMy8weDM1ZQpKYW4gIDQgMTc6MDI6NTAga2lk
cyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIyNl0gIFs8YzEzMTYwNDc+XSA/IHN5c19jb25uZWN0KzB4
NjAvMHg3ZApKYW4gIDQgMTc6MDI6NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIyNl0gIFs8
YzEzMTZiMjk+XSA/IHN5c19zb2NrZXRjYWxsKzB4OGYvMHgxYTUKSmFuICA0IDE3OjAyOjUwIGtp
ZHMga2VybmVsOiBbMTc1NTQ2NS45NTYyMjZdICBbPGMxMDAyNzhjPl0gPyBzeXNlbnRlcl9kb19j
YWxsKzB4MTIvMHgyMgpKYW4gIDQgMTc6MDI6NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY1Ljk1NjIy
Nl0gQ29kZTogNTYgNjggMDAgMDAgMDQgMDAgZTggYmEgZjIgZmYgZmYgOGQgNjUgZjQgNWIgNWUg
NWYgYzkgYzMgNTUgODkgZTUgNTcgOGQgN2QgOTAgNTYgNTMgODMgZWMgNmMgOGIgNDAgMTQgOGIg
NTIgMTQgOGIgOTggNTggMDEgMDAgMDAgPDhiPiA4MiA1OCAwMSAwMCAwMCA4OSA0NSA4YyAzMSBj
MCA4YiBiMSA1OCAwMSAwMCAwMCA4OSA3ZCA4OCBiOQpKYW4gIDQgMTc6MDI6NTAga2lkcyBrZXJu
ZWw6IFsxNzU1NDY1Ljk1NjIyNl0gRUlQOiBbPGMxMTEyOTdlPl0gc2VsaW51eF9zb2NrZXRfdW5p
eF9zdHJlYW1fY29ubmVjdCsweDE4LzB4ODQgU1M6RVNQIDAwNjg6ZjU5YzVlMTQKSmFuICA0IDE3
OjAyOjUwIGtpZHMga2VybmVsOiBbMTc1NTQ2NS45NTYyMjZdIENSMjogMDAwMDAwMDAwMDAwMDE1
OApKYW4gIDQgMTc6MDI6NTAga2lkcyBrZXJuZWw6IFsxNzU1NDY2LjAzNzE3OF0gLS0tWyBlbmQg
dHJhY2UgOWZkMGQ5YjhmZWI3OGU2OSBdLS0tCg==
--000325575ae61248a204991bdc0c--
