From: Jerome Brunet <jbrunet@baylibre.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Thu, 03 Nov 2016 17:36:20 +0100
Message-ID: <1478190980.6632.26.camel@baylibre.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
         <ff6f3501-fbd5-3e79-dcc1-549406a5144b@st.com>
         <CAFBinCD42A_SqQz8GM-H+A32dMELknAytHuJ5T2YgZ3BrMKA3A@mail.gmail.com>
         <20160917232312.1e30d425@gmail.com>
         <d59f6e2c-15ff-779d-da2f-8eb5f5a535a6@st.com>
         <CAFBinCD_-KjVa70iOhBSGaXZc9uKy2m4d2yVr-AfLiV7F=3EqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-PcCb3Muup5YcZka9h+15"
Cc: Johnson Leung <r58129@freescale.com>, netdev@vger.kernel.org,
        =?ISO-8859-1?Q?Andr=E9?= Roth <neolynx@gmail.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-amlogic@lists.infradead.org
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36159 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756145AbcKCQgX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 12:36:23 -0400
Received: by mail-wm0-f42.google.com with SMTP id p190so344817662wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 09:36:23 -0700 (PDT)
In-Reply-To: <CAFBinCD_-KjVa70iOhBSGaXZc9uKy2m4d2yVr-AfLiV7F=3EqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PcCb3Muup5YcZka9h+15
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

On Sat, 2016-10-01 at 17:58 +0200, Martin Blumenstingl wrote:
> Hello Peppe,
> 
> On Mon, Sep 26, 2016 at 8:17 AM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
> > 
> > Hello André
> > 
> > On 9/17/2016 11:23 PM, André Roth wrote:
> > > 
> > > 
> > > 
> > > Hi all,
> > > 
> > > I have an odroid c2 board which shows this issue. No data is
> > > transmitted or received after a moment of intense tx traffic.
> > > Copying a
> > > 1GB file per scp from the board triggers it repeatedly.
> > > 
> > > The board has a stmmac - user ID: 0x11, Synopsys ID: 0x37.
> > > 
> > > When switching the network to 100Mb/s the copying does
> > > not seam to trigger the issue.
> > > 
> > > I've attached the ethtool statistics before and after the
> > > problem.
> > 
> > 
> > at first glance, it enters in EEE mode often in the ethtool.after.
> > On some platforms we met problems and it was necessary to disable
> > the
> > feature. Maybe, you can start looking at if this is true on yours.
> > We will see to provide a clean subset of patches to switch-on/off
> > it.
> I did some hacking in the stmmac driver to disable the LPI stuff (see
> the attachment)
> 
> Unfortunately this did not fix the problem.
> 
> I did not issue any ethtool commands not shown in the logs.
> Also I did not have time to change the AXI tuning / PBL value yet -
> so
> those are also untouched.
> 
> I will keep testing, but unfortunately my device is starting to fall
> apart (I sometimes have DDR initialization issues and u-boot fails to
> come up, oh dear...).

Hi all,

I did several tests on this issue with amlogic's S905 SoC (Synopsys MAC
- user ID: 0x11, Synopsys ID: 0x37.) 

With the OdroidC2 (PHY Realtek RTL8211F), EEE is on by default.
Just before launching iperf3, here are the ethtool stats regarding LPI:
     irq_tx_path_in_lpi_mode_n: 6
     irq_tx_path_exit_lpi_mode_n: 5
     irq_rx_path_in_lpi_mode_n: 76
     irq_rx_path_exit_lpi_mode_n: 75
     phy_eee_wakeup_error_n: 0

Sending data with iperf usually works for little while (between 0 and
10s)

# iperf3 -c 192.168.1.170 -p12345
Connecting to host 192.168.1.170, port 12345
local 192.168.1.30 port 54450 connected to 192.168.1.170 port 12345
Interval           Transfer     Bandwidth       Retr  Cwnd
0.00-1.00   sec   112 MBytes   938 Mbits/sec    0    409 KBytes       
1.00-2.00   sec   112 MBytes   940 Mbits/sec    0    426 KBytes       
2.00-3.00   sec   112 MBytes   939 Mbits/sec    0    426 KBytes       
3.00-4.00   sec   112 MBytes   940 Mbits/sec    0    426 KBytes       
4.00-5.00   sec   112 MBytes   940 Mbits/sec    0    426 KBytes       
5.00-6.00   sec   112 MBytes   939 Mbits/sec    0    426 KBytes       
6.00-7.00   sec  9.26 MBytes  77.6 Mbits/sec    2   1.41 KBytes       
7.00-8.00   sec  0.00 Bytes  0.00 bits/sec    1   1.41 KBytes       
8.00-9.00   sec  0.00 Bytes  0.00 bits/sec    0   1.41 KBytes       
^C10.00-13.58  sec  0.00 Bytes  0.00 bits/sec    1   1.41 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
Interval           Transfer     Bandwidth       Retr
0.00-13.58  sec   681 MBytes   421 Mbits/sec    4             sender
0.00-13.58  sec  0.00 Bytes  0.00 bits/sec                  receiver
iperf3: interrupt - the client has terminated

iperf3 does not exit ant the link seems completely broken. We cannot
send or receive until the interface is brought down then up again.

Here are the LPI related stats after the test:
     irq_tx_path_in_lpi_mode_n: 48
     irq_tx_path_exit_lpi_mode_n: 48
     irq_rx_path_in_lpi_mode_n: 325
     irq_rx_path_exit_lpi_mode_n: 325
     phy_eee_wakeup_error_n: 0

Like Martin, I tried playing around with eee in stmmac, but I could not
improve the situation. Then I tried disabling EEE advertisement on the
PHY (patch attached). With this patch, iperf3 runs nicely for me.

This is what the folks of FreeBSD have done for the Same MAC/PHY
combination [0]

On the P200 Board (PHY Micrel KSZ9031), EEE is off by default. There is
no problem on this board right now. I tried to force the activation of
EEE on this board and ended up in the same situation as the OdroidC2
(link broken). The stats were a bit different though:
     irq_tx_path_in_lpi_mode_n: 28
     irq_tx_path_exit_lpi_mode_n: 28
     irq_rx_path_in_lpi_mode_n: 408
     irq_rx_path_exit_lpi_mode_n: 408
     phy_eee_wakeup_error_n: 5440

To everybody having similar issue with their OdroidC2, could you try
the attached patch and let us know if it changes anything for you ?

Peppe, Alexandre,
What is your view on this ? I'm not sure that removing EEE
advertisement is the right way to address the problem ?
Could it be an issue stmmac ?
If there is any other information / test which would help understand
the issue, please let me know.

Cheers

Jerome


[0] : https://github.com/freebsd/freebsd-base-graphics/commit/1f49e276c
3801545dc0a337792a5f07e6ad39c84
 

> _______________________________________________
> linux-amlogic mailing list
> linux-amlogic@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-amlogic
--=-PcCb3Muup5YcZka9h+15
Content-Disposition: attachment; filename="realtek8211f-disable-eee-1000.patch"
Content-Type: text/x-patch; name="realtek8211f-disable-eee-1000.patch"; charset="UTF-8"
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL2FyY2gvYXJtNjQvYm9vdC9kdHMvYW1sb2dpYy9tZXNvbi1neGJiLW9kcm9p
ZGMyLmR0cyBiL2FyY2gvYXJtNjQvYm9vdC9kdHMvYW1sb2dpYy9tZXNvbi1neGJiLW9kcm9pZGMy
LmR0cwppbmRleCBhNDVkMTAxM2MyMjUuLjNjYmVlYzYzYTQzOSAxMDA2NDQKLS0tIGEvYXJjaC9h
cm02NC9ib290L2R0cy9hbWxvZ2ljL21lc29uLWd4YmItb2Ryb2lkYzIuZHRzCisrKyBiL2FyY2gv
YXJtNjQvYm9vdC9kdHMvYW1sb2dpYy9tZXNvbi1neGJiLW9kcm9pZGMyLmR0cwpAQCAtMTI3LDMg
KzEyNywxOCBAQAogJnVzYjEgewogCXN0YXR1cyA9ICJva2F5IjsKIH07CisKKyZldGhtYWMgewor
CXBoeS1oYW5kbGUgPSA8JmV0aF9waHkwPjsKKworCW1kaW8geworCQljb21wYXRpYmxlID0gInNu
cHMsZHdtYWMtbWRpbyI7CisJCSNhZGRyZXNzLWNlbGxzID0gPDE+OworCQkjc2l6ZS1jZWxscyA9
IDwwPjsKKworCQlldGhfcGh5MDogZXRoZXJuZXQtcGh5QDAgeworCQkJcmVnID0gPDA+OworCQkJ
cmVhbHRlayxkaXNhYmxlLWVlZS0xMDAwdDsKKwkJfTsKKwl9OworfTsKZGlmZiAtLWdpdCBhL2Ry
aXZlcnMvbmV0L3BoeS9yZWFsdGVrLmMgYi9kcml2ZXJzL25ldC9waHkvcmVhbHRlay5jCmluZGV4
IGFhZGQ2ZTlmNTRhZC4uMzBlMjBiYTEwZjQ1IDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9waHkv
cmVhbHRlay5jCisrKyBiL2RyaXZlcnMvbmV0L3BoeS9yZWFsdGVrLmMKQEAgLTE1LDYgKzE1LDEy
IEBACiAgKi8KICNpbmNsdWRlIDxsaW51eC9waHkuaD4KICNpbmNsdWRlIDxsaW51eC9tb2R1bGUu
aD4KKyNpbmNsdWRlIDxsaW51eC9vZi5oPgorCitzdHJ1Y3QgcnRsODIxMWZfcGh5X3ByaXYgewor
CWJvb2wgZWVlXzEwMDBfZGlzYWJsZTsKKwlib29sIGVlZV8xMDBfZGlzYWJsZTsKK307CiAKICNk
ZWZpbmUgUlRMODIxeF9QSFlTUgkJMHgxMQogI2RlZmluZSBSVEw4MjF4X1BIWVNSX0RVUExFWAkw
eDIwMDAKQEAgLTkzLDYgKzk5LDI1IEBAIHN0YXRpYyBpbnQgcnRsODIxMWZfY29uZmlnX2ludHIo
c3RydWN0IHBoeV9kZXZpY2UgKnBoeWRldikKIAlyZXR1cm4gZXJyOwogfQogCitzdGF0aWMgdm9p
ZCBydGw4MjExZl9mb3JjZV9lZWUoc3RydWN0IHBoeV9kZXZpY2UgKnBoeWRldikKK3sKKwlzdHJ1
Y3QgcnRsODIxMWZfcGh5X3ByaXYgKnByaXYgPSBwaHlkZXYtPnByaXY7CisJdTE2IHZhbDsKKwor
CWlmIChwcml2LT5lZWVfMTAwMF9kaXNhYmxlIHx8IHByaXYtPmVlZV8xMDBfZGlzYWJsZSkgewor
CQl2YWwgPSBwaHlfcmVhZF9tbWRfaW5kaXJlY3QocGh5ZGV2LCBNRElPX0FOX0VFRV9BRFYsCisJ
CQkJCSAgICBNRElPX01NRF9BTik7CisKKwkJaWYgKHByaXYtPmVlZV8xMDAwX2Rpc2FibGUpCisJ
CQl2YWwgJj0gfk1ESU9fQU5fRUVFX0FEVl8xMDAwVDsKKwkJaWYgKHByaXYtPmVlZV8xMDBfZGlz
YWJsZSkKKwkJCXZhbCAmPSB+TURJT19BTl9FRUVfQURWXzEwMFRYOworCisJCXBoeV93cml0ZV9t
bWRfaW5kaXJlY3QocGh5ZGV2LCBNRElPX0FOX0VFRV9BRFYsCisJCQkJICAgICAgIE1ESU9fTU1E
X0FOLCB2YWwpOworCX0KK30KKwogc3RhdGljIGludCBydGw4MjExZl9jb25maWdfaW5pdChzdHJ1
Y3QgcGh5X2RldmljZSAqcGh5ZGV2KQogewogCWludCByZXQ7CkBAIC0xMDIsNiArMTI3LDggQEAg
c3RhdGljIGludCBydGw4MjExZl9jb25maWdfaW5pdChzdHJ1Y3QgcGh5X2RldmljZSAqcGh5ZGV2
KQogCWlmIChyZXQgPCAwKQogCQlyZXR1cm4gcmV0OwogCisJcnRsODIxMWZfZm9yY2VfZWVlKHBo
eWRldik7CisKIAlpZiAocGh5ZGV2LT5pbnRlcmZhY2UgPT0gUEhZX0lOVEVSRkFDRV9NT0RFX1JH
TUlJKSB7CiAJCS8qIGVuYWJsZSBUWERMWSAqLwogCQlwaHlfd3JpdGUocGh5ZGV2LCBSVEw4MjEx
Rl9QQUdFX1NFTEVDVCwgMHhkMDgpOwpAQCAtMTE1LDYgKzE0MiwyNiBAQCBzdGF0aWMgaW50IHJ0
bDgyMTFmX2NvbmZpZ19pbml0KHN0cnVjdCBwaHlfZGV2aWNlICpwaHlkZXYpCiAJcmV0dXJuIDA7
CiB9CiAKK3N0YXRpYyBpbnQgcnRsODIxMWZfcGh5X3Byb2JlKHN0cnVjdCBwaHlfZGV2aWNlICpw
aHlkZXYpCit7CisJc3RydWN0IGRldmljZSAqZGV2ID0gJnBoeWRldi0+bWRpby5kZXY7CisJc3Ry
dWN0IGRldmljZV9ub2RlICpvZl9ub2RlID0gZGV2LT5vZl9ub2RlOworCXN0cnVjdCBydGw4MjEx
Zl9waHlfcHJpdiAqcHJpdjsKKworCXByaXYgPSBkZXZtX2t6YWxsb2MoZGV2LCBzaXplb2YoKnBy
aXYpLCBHRlBfS0VSTkVMKTsKKwlpZiAoIXByaXYpCisJCXJldHVybiAtRU5PTUVNOworCisJaWYg
KG9mX3Byb3BlcnR5X3JlYWRfYm9vbChvZl9ub2RlLCAicmVhbHRlayxkaXNhYmxlLWVlZS0xMDAw
dCIpKQorCQlwcml2LT5lZWVfMTAwMF9kaXNhYmxlPSB0cnVlOworCWlmIChvZl9wcm9wZXJ0eV9y
ZWFkX2Jvb2wob2Zfbm9kZSwgInJlYWx0ZWssZGlzYWJsZS1lZWUtMTAwdCIpKQorCQlwcml2LT5l
ZWVfMTAwX2Rpc2FibGU9IHRydWU7CisKKwlwaHlkZXYtPnByaXYgPSBwcml2OworCisJcmV0dXJu
IDA7Cit9CisKIHN0YXRpYyBzdHJ1Y3QgcGh5X2RyaXZlciByZWFsdGVrX2RydnNbXSA9IHsKIAl7
CiAJCS5waHlfaWQgICAgICAgICA9IDB4MDAwMDgyMDEsCkBAIC0xNjQsNiArMjExLDcgQEAgc3Rh
dGljIHN0cnVjdCBwaHlfZHJpdmVyIHJlYWx0ZWtfZHJ2c1tdID0gewogCQkucGh5X2lkX21hc2sJ
PSAweDAwMWZmZmZmLAogCQkuZmVhdHVyZXMJPSBQSFlfR0JJVF9GRUFUVVJFUywKIAkJLmZsYWdz
CQk9IFBIWV9IQVNfSU5URVJSVVBULAorCQkucHJvYmUJCT0gJnJ0bDgyMTFmX3BoeV9wcm9iZSwK
IAkJLmNvbmZpZ19hbmVnCT0gJmdlbnBoeV9jb25maWdfYW5lZywKIAkJLmNvbmZpZ19pbml0CT0g
JnJ0bDgyMTFmX2NvbmZpZ19pbml0LAogCQkucmVhZF9zdGF0dXMJPSAmZ2VucGh5X3JlYWRfc3Rh
dHVzLAo=


--=-PcCb3Muup5YcZka9h+15--
