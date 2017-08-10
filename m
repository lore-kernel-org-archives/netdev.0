From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH V5 1/2] firmware: add more flexible
 request_firmware_async function
Date: Thu, 10 Aug 2017 19:05:39 +0200
Message-ID: <20170810170539.GC27873@wotan.suse.de>
References: <20170731150945.8925-1-zajec5@gmail.com>
 <20170802213010.GM18884@wotan.suse.de>
 <878tj1ql6z.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>,
        =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Daniel Wagner <wagi@monom.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        "Rafael J . Wysocki" <rjw@rjwysocki.net>, yi1.li@linux.intel.com,
        atull@kernel.org, Moritz Fischer <moritz.fischer@ettus.com>,
        pmladek@suse.com, Johannes Berg <johannes.berg@intel.com>,
        emmanuel.grumbach@intel.com, luciano.coelho@intel.com,
        luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        AKASHI Takahiro <takahiro.akashi@linaro.org>,
        David Howells <dhowells@redhat.com>, pjones@redhat.com,
        Hans de Goede <hdegoede@
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <878tj1ql6z.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2017 at 08:23:00AM +0300, Kalle Valo wrote:
> "Luis R. Rodriguez" <mcgrof@kernel.org> writes:
> 
> >> +int request_firmware_nowait(struct module *module, bool uevent,
> >> +			    const char *name, struct device *device, gfp_t gfp,
> >> +			    void *context,
> >> +			    void (*cont)(const struct firmware *fw, void *context))
> >> +{
> >> +	unsigned int opt_flags = FW_OPT_FALLBACK |
> >> +		(uevent ? FW_OPT_UEVENT : FW_OPT_USERHELPER);
> >> +
> >> +	return __request_firmware_nowait(module, opt_flags, name, device, gfp,
> >> +					 context, cont);
> >> +}
> >>  EXPORT_SYMBOL(request_firmware_nowait);
> >>  
> >> +int __request_firmware_async(struct module *module, const char *name,
> >> +			     struct firmware_opts *fw_opts, struct device *dev,
> >> +			     void *context,
> >> +			     void (*cont)(const struct firmware *fw, void *context))
> >> +{
> >> +	unsigned int opt_flags = FW_OPT_UEVENT;
> >
> > This exposes a long issue. Think -- why do we want this enabled by default? Its
> > actually because even though the fallback stuff is optional and can be, the uevent
> > internal flag *also* provides caching support as a side consequence only. We
> > don't want to add a new API without first cleaning up that mess.
> >
> > This is a slipery slope and best to clean that up before adding any new API.
> >
> > That and also Greg recently stated he would like to see at least 3 users of
> > a feature before adding it. Although I think that's pretty arbitrary, and
> > considering that request_firmware_into_buf() only has *one* user -- its what
> > he wishes.
> 
> ath10k at least needs a way to silence the warning for missing firmware
> and I think iwlwifi also.

It would seem ath10k actually does not need an async version of the no-warn
thing proposed here.

Below an analysis of how ath10k uses the firmware API. Note that I think
that iwlwifi may be on the same boat but the case and issue is slightly
different: both drivers use an API revision scheme, intermediate files
which are not found are not fatal as revisions go from min..max and only
one file is needed. A warning may be needed only if *no* file is found
at all.

I had proposed a new API call to handle this in the driver API series but
had only converted iwlwifi. It would seem ath10k can also be converted to
it and also they could end up sharing the same revision loop scheme so
less code on both drivers.

Below my analysis of how ath10k uses the firmware API:

You noted in private that ath10k long ago addressed the warning issue by
switching to request_firmware_direct() entirely:

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=9f5bcfe93315d75da4cc46bd30b536966559359a

Below is a list of the file name schemes used for all the different firmwares
types used in ath10k:

1)
        /* pre-cal-<bus>-<id>.bin */                                            
        scnprintf(filename, sizeof(filename), "pre-cal-%s-%s.bin", 

2)

        /* cal-<bus>-<id>.bin */                                                
        scnprintf(filename, sizeof(filename), "cal-%s-%s.bin",                  
                  ath10k_bus_str(ar->hif.bus), dev_name(ar->dev)); 


This seems fine as-is if indeed they are optional.

3) ath10k_core_fetch_board_data_api_1():

ar->hw_params.fw.dir/ar->hw_params.fw.board

This seems fine if indeed its optional.

3) Then you have a board file on ath10k_core_fetch_board_data_api_n():

boardname/ATH10K_BOARD_API2_FILE

This seems fine if indeed its optional.

4) Finally you have the actual firmware files which use a revision scheme
in ath10k_core_fetch_firmware_api_n():

        for (i = ATH10K_FW_API_MAX; i >= ATH10K_FW_API_MIN; i--) {              
                ar->fw_api = i;                                                 
                ath10k_dbg(ar, ATH10K_DBG_BOOT, "trying fw api %d\n",           
                           ar->fw_api);                                         
                                                                                
                ath10k_core_get_fw_name(ar, fw_name, sizeof(fw_name), ar->fw_api);
                ret = ath10k_core_fetch_firmware_api_n(ar, fw_name,             
                                                       &ar->normal_mode_fw.fw_file);
                if (!ret)                                                       
                        goto success;                                           
        }    

This ends up using the ar->hw_params.fw.dir/fw_name but fw_name is constructed
above using a API revision scheme. The fw_name can be of two types as per
ath10k_core_get_fw_name():

For SDIO:

                scnprintf(fw_name, fw_name_len, "%s-%s-%d.bin",                 
                          ATH10K_FW_FILE_BASE, ath10k_bus_str(ar->hif.bus),     
                          fw_api); 

For PCI/AHB:

                scnprintf(fw_name, fw_name_len, "%s-%d.bin",                    
                          ATH10K_FW_FILE_BASE, fw_api);   

For this the problem is at least one firmware is required so no complaint is
issued using request_firmware_direct() at all so you have to do that yourself
on ath10k_core_fetch_firmware_files():

                                                                                
        /* we end up here if we couldn't fetch any firmware */                  
    
        ath10k_err(ar, "Failed to find firmware-N.bin (N between %d and %d) from %s: %d",
                   ATH10K_FW_API_MIN, ATH10K_FW_API_MAX, ar->hw_params.fw.dir,  
                   ret);  

This is *fine* as per the API but it just means you are troubled to keep this
error warning. Correct me if I'm wrong but this does not seem to me like a big
issue and your issue is not in any way related to the patch proposed.

*But* the whole API revision scheme is something I figured could be generalized
and have code which lets us specify a name template, and let the driver
specific a series of API revision numbers and then the firmware API will do the
hunting for us. Then at least one API versioned file is hunted for. Since you
got from ATH10K_FW_API_MAX (6) down to ATH10K_FW_API_MIN (2) and I had used u8
for it then we have a match in terms of compatibility.

Turns out Intel uses a similar scheme, this is what it would look like for
iwlwifi to change to it, your driver similarly could cope:

https://lkml.kernel.org/r/20170605213937.26215-6-mcgrof@kernel.org

If this seems appealing I could do the conversion for you later once
I add this upstream. I'd need one more driver which has a similar API
revision scheme.

 Luis
