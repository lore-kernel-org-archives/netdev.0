From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: rtl8192se firmware load can overflow target
 buffer
Date: Thu, 09 Feb 2012 10:43:52 -0600
Message-ID: <4F33F7C8.2090105@lwfinger.net>
References: <1328735291-33220-1-git-send-email-tim.gardner@canonical.com> <1328737514.2627.14.camel@bwh-desktop> <4F332FC3.7000808@lwfinger.net> <4F33DAFC.1000502@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tim Gardner <rtg.canonical@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tim.gardner@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F33DAFC.1000502@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/09/2012 08:41 AM, Tim Gardner wrote:
>
> I agree with you about the semantics of rtlpriv->max_fw_size, but I don't agree
> that the size check is correct. While rtlpriv->max_fw_size has been set to
> sizeof(struct rt_firmware), that value is _way_ bigger then the size of the
> target buffer.
>
> sizeof(struct rt_firmware) == 64000+64000+164000 plus some change
>
> The target buffer size is only 164000 bytes.
>
> I've attached v2 of the patch that is simpler and may serve to better illustrate
> my point. By the way, Ben Hutchings was right about the original patch having an
> off by one error. This version also clears rtlpriv->max_fw_size if the size
> check fails. Probably should have mentioned that in the commit log.

I agree that Ben is right.

This thread forced me to go back to square one in analyzing the situation. For 
the other drivers in the rtlwifi family, the firmware file contains an image 
that is directly stuffed into the device. For the RTL8192SE devices, it is more 
complicated. The structure is described in struct rt_firmware. At the moment, 
the arrays there are grossly oversized. They could be as follows:

struct rt_firmware {
         struct fw_hdr *pfwheader;
         enum fw_status fwstatus;
         u16 firmwareversion;
         u8 fw_imem[RTL8190_MAX_IMEM_CODE_SIZE];
         u8 fw_emem[RTL8190_MAX_DMEM_CODE_SIZE];
         u32 fw_imem_len;
         u32 fw_emem_len;
         u8 sz_fw_tmpbuffer[RTL8190_MAX_FIRMWARE_SIZE];
         u32 sz_fw_tmpbufferlen;
         u16 cmdpacket_fragthresold;
};

with

RTL8190_MAX_IMEM_CODE_SIZE = 54000 (current fw is 51,208), 
RTL8190_MAX_DMEM_CODE_SIZE = 40000 (current fw is 37,520), and 
RTL8190_MAX_FIRMWARE_SIZE = 90000 (it holds the raw firmware image, which is 
currently 88,856).

Ultimately, all three arrays should be eliminated. Now that we are using 
asynchronous loading, the kernel should keep its cached data and not copy it 
into the driver's private storage when a pointer will suffice. All the drivers 
need this change, but that can wait for now.

I will ACK the patch if you resumit it with
#define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE	90000

Larry
